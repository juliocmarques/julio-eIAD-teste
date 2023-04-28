#!/bin/bash

set -e

# Get the directory that this script is in
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# Get env vars for workspace from Terraform outputs
source "${DIR}/environments/infrastructure.env"

figlet Clean Synapse Artifacts

# This is called if we are in a CI system and we will login
# with a Service Principal.
if [ -n "${TF_IN_AUTOMATION}" ]
then
    az login --service-principal -u "$ARM_CLIENT_ID" -p "$ARM_CLIENT_SECRET" --tenant "$ARM_TENANT_ID"
    az account set -s "$ARM_SUBSCRIPTION_ID"
fi

# The types of Synapse artifacts to delete (has to be exact name for the az cli synapse subcommands)
ARTIFACT_TYPES=("trigger" "pipeline" "notebook" "dataset")

deleteArtifacts() {
    for artifact_type in ${ARTIFACT_TYPES[@]}; do
        echo "Deleting ${artifact_type}s..."
        ARTIFACTS=$(az synapse ${artifact_type} list --workspace-name ${SYNAPSE_WORKSPACE_NAME} --query [].name --output json | jq -c -r '.[]')
        for artifact in $ARTIFACTS; do

            # If a trigger, we must make sure it's stopped before deleting
            if [[ "${artifact_type}" == "trigger" ]]; then
                echo "Stopping trigger: ${artifact}"
                az synapse trigger stop --name "${artifact}" --workspace-name "${SYNAPSE_WORKSPACE_NAME}"
            fi

            echo "Deleting Synapse ${artifact_type}: ${artifact}"
            az synapse ${artifact_type} delete --name "${artifact}" --workspace-name "${SYNAPSE_WORKSPACE_NAME}" --yes -o json
        done
    done
}

# Delete all artifacts
# This line allows the spark pool to be available
az synapse spark session list --workspace-name "${SYNAPSE_WORKSPACE_NAME}" --spark-pool-name "${SPARK_POOL_NAME}" -o none
deleteArtifacts

echo "Completed deleting Synapse artifacts."