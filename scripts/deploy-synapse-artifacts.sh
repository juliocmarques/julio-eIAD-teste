#!/bin/bash

set -e

# Get the directory that this script is in
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# Get env vars for workspace from Terraform outputs
source "${DIR}/environments/infrastructure.env"

# load env vars
source "${DIR}/load-env.sh"

figlet Deploy Synapse Artifacts

# This is called if we are in a CI system and we will login
# with a Service Principal.
if [[ -n "${TF_IN_AUTOMATION}" ]]; then
    az login --service-principal -u "$ARM_CLIENT_ID" -p "$ARM_CLIENT_SECRET" --tenant "$ARM_TENANT_ID"
    az account set -s "$ARM_SUBSCRIPTION_ID"
fi

# The types of Synapse artifacts to create (has to be exact name for the az cli synapse subcommands)
# Order is also important as there are dependencies which will cause failures if deployed in the wrong order
ARTIFACT_TYPES=("dataset" "notebook" "pipeline") #"trigger"

# Tokens to replace in the artifact files (due to the inability to pass a storage scope dynamically to a blob trigger
# for example, we need to do this ourselves to allow changing the storage resource id dynamically depending on environment)
if [[ -z "$STORAGE_ACCOUNT_ID" ]]; then
    echo "STORAGE_ACCOUNT_ID not set"
    exit 1
fi
if [[ -z "$STORAGE_ACCOUNT_NAME" ]]; then
    echo "STORAGE_ACCOUNT_NAME not set"
    exit 1
fi
if [[ -z "$KEY_VAULT_NAME" ]]; then
    echo "KEY_VAULT_NAME not set"
    exit 1
fi

declare -A REPLACE_TOKENS=(
    [<<STORAGE_ACCOUNT_ID>>]=${STORAGE_ACCOUNT_ID}
    [<<STORAGE_ACCOUNT_NAME>>]=${STORAGE_ACCOUNT_NAME}
    [<<KEY_VAULT_NAME>>]=${KEY_VAULT_NAME}
    [<<SUBSCRIPTION_ID>>]=${SUBSCRIPTION_ID}
    [<<RESOURCE_GROUP>>]=${RESOURCE_GROUP}
    [<<SYNAPSE_WORKSPACE_NAME>>]=${SYNAPSE_WORKSPACE_NAME}
    [<<SPARK_POOL_NAME>>]=${SPARK_POOL_NAME}
)

createArtifacts() {
    
    # create tmp location for files and outputs
    tmp_folder=/tmp/synapse_artifacts/outputs
    tmp_folder_outputs=$tmp_folder/output/
    mkdir -p $tmp_folder_outputs
    
    # Iterate over the specified artifact types
    for artifact_type in ${ARTIFACT_TYPES[@]}; do
        echo "Creating ${artifact_type}s..."

        # Add additional arguments depending on artifact type
        args=()
        # Specify a Spark pool to attach notebooks to
        [[ "${artifact_type}" == "notebook" ]] && args+=( "--spark-pool-name" "${SPARK_POOL_NAME}" )

        # Iterate over the files within that artifact type's directory
        for artifact in "${DIR}/../synapse/${artifact_type}"/*; do
            artifact_file="${artifact##*/}"
            artifact_name="${artifact_file%%.*}"

            # Just load the artifact
            artifact_json=$(cat "$artifact")

            # Replace tokens
            for token in "${!REPLACE_TOKENS[@]}"
            do
                artifact_json="${artifact_json//"$token"/"${REPLACE_TOKENS[$token]}"}"
            done

            # printf artifact json to tmp file, maintaining formattting
            printf "%s" "$artifact_json" > "${tmp_folder}/${artifact_file}"
            
            # If a trigger, try stopping it first (ignoring doesn't exist or already stopped errors) so we can update it
            if [[ "${artifact_type}" == "trigger" ]]; then
                echo "Stopping ${artifact_name} trigger if it exists so we can update it..."
                az synapse trigger stop --name "${artifact_name}" --workspace-name "${SYNAPSE_WORKSPACE_NAME}" || true
            fi

            # Create artifact using az cli
            echo "Creating Synapse ${artifact_type}: ${artifact_name}"
            az synapse ${artifact_type} create --file ""@"$tmp_folder/$artifact_file""" --name "${artifact_name}"\
                --workspace-name "${SYNAPSE_WORKSPACE_NAME}" "${args[@]}" --output json > ${tmp_folder_outputs}/"${artifact_file}"
                
            # detect errors by looking for error node in output json
            error_node=$(jq  -r '.error | select (.!=null)' "${tmp_folder_outputs}/${artifact_file}")
            if [[ -z "$error_node" ]]; then
                echo "Success creating ${artifact_type}: ${artifact_name}"
            else
                echo "FAILED to create ${artifact_type}: ${artifact_name}"
                echo "ERROR: $error_node"                
                exit 1
            fi
            
            # If a trigger, it will need to be started following creation (unless DISABLE_START_TRIGGERS has been set)
            if [[ "${artifact_type}" == "trigger" ]]; then        
                if [[ -z "${DISABLE_START_TRIGGERS}" ]]; then
                    echo "Starting trigger: ${artifact_name}"
                    az synapse trigger start --name "${artifact_name}" --workspace-name "${SYNAPSE_WORKSPACE_NAME}" --output json > "${tmp_folder_outputs}/${artifact_file}.trigger_start.json"
                    
                    # detect errors by looking for error node in output json
                    error_node=$(jq  -r '.error | select (.!=null)' "${tmp_folder_outputs}/${artifact_file}.trigger_start.json")
                    if [[ -z "$error_node" ]]; then
                        echo "Success starting trigger: ${artifact_name}"
                    else
                        echo "FAILED to start trigger: ${artifact_name}"
                        echo "ERROR: $error_node"
                        exit 1
                    fi
                else
                    echo "Trigger ${artifact_name} was NOT started (DISABLE_START_TRIGGERS is set)"
                fi
            fi
            
        done
    done
    
    # delete tmp folder for artifact files
    rm -r $tmp_folder
}

# Deploy all artifacts
# This line allows the spark pool to be available to attach notebooks to
az synapse spark session list --workspace-name "${SYNAPSE_WORKSPACE_NAME}" --spark-pool-name "${SPARK_POOL_NAME}" --output none
createArtifacts

echo "Completed deploying Synapse artifacts."