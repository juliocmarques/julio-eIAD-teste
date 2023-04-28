#!/bin/bash

set -e

# Get the directory that this script is in
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# Get env vars for workspace from Terraform outputs
source "${DIR}/environments/infrastructure.env"

# load env vars
source "${DIR}/load-env.sh"

figlet Deploy Synapse Packages

waitForDeployment()
{
    #With REST APIs the bigDataPool update command returns upon successful submission.
    # we must query the bigDataPool object to determine the "provisioningStatus"
    provisioningState=$(az rest --method GET --url https://management.azure.com/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Synapse/workspaces/${SYNAPSE_WORKSPACE_NAME}/bigDataPools/${SPARK_POOL_NAME}?api-version=2021-06-01 --output tsv --query "properties.provisioningState")
    echo "State of Spark Pool is: ${provisioningState}"
    while [ ${provisioningState} != "Succeeded" ]
    do
        #wait 10 seconds
        echo "Waiting 30s"
        sleep 30

        provisioningState=$(az rest --method GET --url https://management.azure.com/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Synapse/workspaces/${SYNAPSE_WORKSPACE_NAME}/bigDataPools/${SPARK_POOL_NAME}?api-version=2021-06-01 --output tsv --query "properties.provisioningState")
        echo "Spark Pool state is: ${provisioningState}"
        if [ ${provisioningState} == "Failed" ]
        then
            exit 1
        fi
    done
}

# This is called if we are in a CI system and we will login
# with a Service Principal.
if [ -n "${TF_IN_AUTOMATION}" ]
then
    az login --service-principal -u "$ARM_CLIENT_ID" -p "$ARM_CLIENT_SECRET" --tenant "$ARM_TENANT_ID"
    az account set -s "$ARM_SUBSCRIPTION_ID"
fi

# Deploy custom libraries as workspace packages and reference them in the pool.
# download packages locally, use cli auth
LOCAL_PACKAGE_DIR="./artifacts/custompackages" 
rm -rf $LOCAL_PACKAGE_DIR
mkdir -p $LOCAL_PACKAGE_DIR

if [ "${SYNAPSE_CUSTOM_PACKAGE_DIR}" == "" ]
then
    echo "No workspace packages to use."
else
    echo "Downloading packages from ${SYNAPSE_CUSTOM_PACKAGE_CONTAINER}/${SYNAPSE_CUSTOM_PACKAGE_DIR} ..."

    # get the Workspace packages
    az storage copy \
        --source "${SYNAPSE_CUSTOM_PACKAGE_CONTAINER}/${SYNAPSE_CUSTOM_PACKAGE_DIR}${SYNAPSE_CUSTOM_PACKAGE_CONTAINER_SAS}" \
        --destination ${LOCAL_PACKAGE_DIR} \
        --recursive
fi

# get the names of the packages and delete the ones we want to replace
#echo "az synapse workspace-package list --workspace-name \"${SYNAPSE_WORKSPACE_NAME}\" --output tsv --query \"[].name\""
DEPLOYED_PACKAGES=($(az synapse workspace-package list --workspace-name "${SYNAPSE_WORKSPACE_NAME}" --output tsv --query "[].name"))
LOCAL_PACKAGES=($(ls "${LOCAL_PACKAGE_DIR}/${SYNAPSE_CUSTOM_PACKAGE_DIR}"))
PACKAGES_TO_REMOVE=()
PACKAGES_TO_KEEP=()

for DEPLOYED_PACKAGE in ${DEPLOYED_PACKAGES[*]}
do
    for LOCAL_PACKAGE in ${LOCAL_PACKAGES[*]}
    do
        if [ $LOCAL_PACKAGE == $DEPLOYED_PACKAGE ]
        then
            PACKAGES_TO_REMOVE+=($DEPLOYED_PACKAGE)                
        fi
    done
done
PACKAGES_TO_KEEP=${DEPLOYED_PACKAGES}
for DEPLOYED_PACKAGE in ${DEPLOYED_PACKAGES[*]}
do
    for PACKAGE_TO_REMOVE in ${PACKAGES_TO_REMOVE}
    do
        if [ $PACKAGE_TO_REMOVE == $DEPLOYED_PACKAGE ]
        then
            PACKAGES_TO_KEEP=("${PACKAGES_TO_KEEP[@]/$DEPLOYED_PACKAGE}")
        fi
    done
done

headers="Content-type=application/json"
libraryRequirements=$(cat ./synapse/spark_pool/environment.yml)
sparkConfiguration=$(cat ./synapse/spark_pool/config.txt)
sparkConfiguration=${sparkConfiguration//"\${storage_account_name}"/${STORAGE_ACCOUNT_NAME}}
sparkConfiguration=${sparkConfiguration//"\${key_vault_name}"/${KEY_VAULT_NAME}}
sparkConfiguration=${sparkConfiguration//"\${azure_monitor_workspace_id}"/${AZURE_MONITOR_WORKSPACE_ID}}

# Clear out the packages for the pool
# Does the pool have any packages? If not, a Remove op will fail as the customLibraries property is null rather than []
#echo "az rest --method GET --url https://management.azure.com/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Synapse/workspaces/${SYNAPSE_WORKSPACE_NAME}/bigDataPools/${SPARK_POOL_NAME}?api-version=2021-06-01 --output tsv --query \"properties.customLibraries[].name\""
CUSTOM_LIBS=($(az rest --method GET --url https://management.azure.com/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Synapse/workspaces/${SYNAPSE_WORKSPACE_NAME}/bigDataPools/${SPARK_POOL_NAME}?api-version=2021-06-01 --output tsv --query "properties.customLibraries[].name"))
echo "Loaded CUSTOM_LIBS"
if [ ${#CUSTOM_LIBS[@]} -gt 0 ]
then
    echo "Pool has libaries, will remove existing custom libraries..."
    customLibraries=""
    for PACKAGE_TO_KEEP in ${PACKAGES_TO_KEEP[*]}
    do
        file_ext=${PACKAGE_TO_KEEP##*.}
        customLibraries+="{\"containerName\": \"prep\",\"name\": \"${PACKAGE_TO_KEEP}\",\"path\": \"${SYNAPSE_WORKSPACE_NAME}/libraries/${PACKAGE_TO_KEEP}\",\"type\": \"${file_ext}\"},"
    done
    if [ ${#PACKAGES_TO_KEEP[@]} -gt 0 ] && [ "${PACKAGES_TO_KEEP[*]}" != "" ]
    then
        customLibraries=${customLibraries::-1}
    fi

    # There are three places in this script where the Synapse Spark Pool configuration JSON are defined. Make sure the definitions of the Spark Pool properties here 
    # match what is used in Terraform in /infrastructure/modules/synapse/main.tf 
    body="{\"location\": \"${TF_VAR_location}\",\"properties\": {\"autoPause\": {\"enabled\": true,\"delayInMinutes\": 15},\"nodeSizeFamily\": \"MemoryOptimized\",\"nodeSize\": \"Large\",\"sparkVersion\": \"3.2\",\"autoScale\": {\"enabled\": false},\"nodeCount\": ${SYNAPSE_SPARK_NODE_COUNT},\"customLibraries\": [${customLibraries}],\"libraryRequirements\": {},\"sparkConfigProperties\": {\"configurationType\": \"File\",\"content\": \"${sparkConfiguration}\",\"filename\": \"config.txt\"}}}"
    #echo "az rest --method PUT --url https://management.azure.com/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Synapse/workspaces/${SYNAPSE_WORKSPACE_NAME}/bigDataPools/${SPARK_POOL_NAME}?api-version=2021-06-01 --headers \"${headers}\" --body \"${body}\""
    status=$(az rest --method PUT --url https://management.azure.com/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Synapse/workspaces/${SYNAPSE_WORKSPACE_NAME}/bigDataPools/${SPARK_POOL_NAME}?api-version=2021-06-01 --headers "${headers}" --body "${body}")
    waitForDeployment
else
    echo "Custom libraries do not exist in cluster, skipping remove of custom libraries"
fi

# Are there workspace packages we need to remove?
if [ ${#PACKAGES_TO_REMOVE[@]} -gt 0 ]
then
    echo "Will remove the following packages from the workspace before replacing them: ${PACKAGES_TO_REMOVE[*]}"

 
    for PACKAGE_TO_REMOVE in ${PACKAGES_TO_REMOVE[*]}
    do
        echo "Deleting workspace package '${PACKAGE_TO_REMOVE}'"
        #echo "az synapse workspace-package delete --workspace-name \"${SYNAPSE_WORKSPACE_NAME}\" --name \"${PACKAGE_TO_REMOVE}\" --yes"
        az synapse workspace-package delete --workspace-name "${SYNAPSE_WORKSPACE_NAME}" --name "${PACKAGE_TO_REMOVE}" --yes
    done
else
    echo "No workspace packages to remove"
fi

# upload packages as workspace packages
echo 'Uploading batch of packages'
#echo "az synapse workspace-package upload-batch --workspace-name \"${SYNAPSE_WORKSPACE_NAME}\" --source \"${LOCAL_PACKAGE_DIR}\""
az synapse workspace-package upload-batch --workspace-name "${SYNAPSE_WORKSPACE_NAME}" --source "${LOCAL_PACKAGE_DIR}" --output none

if [ ${#LOCAL_PACKAGES[@]} -gt 0 ]
then
    echo "Recreating spark pool with packages and library requirements"
    
    customLibraries=""
    for LOCAL_PACKAGE in ${LOCAL_PACKAGES[*]}
    do
        file_ext=${LOCAL_PACKAGE##*.}
        customLibraries+="{\"containerName\": \"prep\",\"name\": \"${LOCAL_PACKAGE}\",\"path\": \"${SYNAPSE_WORKSPACE_NAME}/libraries/${LOCAL_PACKAGE}\",\"type\": \"${file_ext}\"},"
    done
    if [ ${#LOCAL_PACKAGE[@]} -gt 0 ]
    then
        customLibraries=${customLibraries::-1}
    fi

    body="{\"location\": \"${TF_VAR_location}\",\"properties\": {\"autoPause\": {\"enabled\": true,\"delayInMinutes\": 15},\"nodeSizeFamily\": \"MemoryOptimized\",\"nodeSize\": \"Large\",\"sparkVersion\": \"3.2\",\"autoScale\": {\"enabled\": false},\"nodeCount\": ${SYNAPSE_SPARK_NODE_COUNT},\"customLibraries\": [${customLibraries}],\"libraryRequirements\": {\"content\": \"${libraryRequirements}\",\"filename\": \"environment.yml\"},\"sparkConfigProperties\": {\"configurationType\": \"File\",\"content\": \"${sparkConfiguration}\",\"filename\": \"config.txt\"}}}"
    #echo "az rest --method PUT --url https://management.azure.com/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Synapse/workspaces/${SYNAPSE_WORKSPACE_NAME}/bigDataPools/${SPARK_POOL_NAME}?api-version=2021-06-01 --headers \"${headers}\" --body \"${body}\""
    status=$(az rest --method PUT --url https://management.azure.com/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Synapse/workspaces/${SYNAPSE_WORKSPACE_NAME}/bigDataPools/${SPARK_POOL_NAME}?api-version=2021-06-01 --headers "${headers}" --body "${body}")
    waitForDeployment
else
    echo "Recreating spark pool with library requirements"
    body="{\"location\": \"${TF_VAR_location}\",\"properties\": {\"autoPause\": {\"enabled\": true,\"delayInMinutes\": 15},\"nodeSizeFamily\": \"MemoryOptimized\",\"nodeSize\": \"Large\",\"sparkVersion\": \"3.2\",\"autoScale\": {\"enabled\": false},\"nodeCount\": ${SYNAPSE_SPARK_NODE_COUNT},\"customLibraries\": [],\"libraryRequirements\": {\"content\": \"${libraryRequirements}\",\"filename\": \"environment.yml\"},\"sparkConfigProperties\": {\"configurationType\": \"File\",\"content\": \"${sparkConfiguration}\",\"filename\": \"config.txt\"}}}"
    
    #echo "az rest --method PUT --url https://management.azure.com/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Synapse/workspaces/${SYNAPSE_WORKSPACE_NAME}/bigDataPools/${SPARK_POOL_NAME}?api-version=2021-06-01 --headers \"${headers}\" --body \"${body}\""
    status=$(az rest --method PUT --url https://management.azure.com/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Synapse/workspaces/${SYNAPSE_WORKSPACE_NAME}/bigDataPools/${SPARK_POOL_NAME}?api-version=2021-06-01 --headers "${headers}" --body "${body}")
    waitForDeployment
fi


echo "Completed deploying Synapse packages."