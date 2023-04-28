#!/bin/bash

set -e

# Get the directory that this script is in
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# Get Synapse instance from previously build infrastructure
source "${DIR}/environments/infrastructure.env"

# load env vars
source "${DIR}/load-env.sh"

figlet Pull Synapse Artifacts

# Tokens to replace in the artifact files (due to the inability to pass a storage scope dynamically to a blob trigger
# for example, we need to do this ourselves to allow changing the storage resource id dynamically depending on environment)
if [[ -z "$SYNAPSE_WORKSPACE_ID" ]]; then
    echo "SYNAPSE_WORKSPACE_ID not set"
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
if [[ -z "$SUBSCRIPTION_ID" ]]; then
    echo "SUBSCRIPTION_ID not set"
    exit 1
fi
if [[ -z "$RESOURCE_GROUP" ]]; then
    echo "RESOURCE_GROUP not set"
    exit 1
fi
if [[ -z "$SYNAPSE_WORKSPACE_NAME" ]]; then
    echo "SYNAPSE_WORKSPACE_NAME not set"
    exit 1
fi

declare -A REPLACE_TOKENS=(
    [${STORAGE_ACCOUNT_ID}]="<<STORAGE_ACCOUNT_ID>>"
    [${SYNAPSE_WORKSPACE_ID}]="<<SYNAPSE_WORKSPACE_ID>>"
    [${SUBSCRIPTION_ID}]="<<SUBSCRIPTION_ID>>"
    [${RESOURCE_GROUP}]="<<RESOURCE_GROUP>>"
    [${STORAGE_ACCOUNT_NAME}]="<<STORAGE_ACCOUNT_NAME>>"
    [${KEY_VAULT_NAME}]="<<KEY_VAULT_NAME>>"
    [${SYNAPSE_WORKSPACE_NAME}]="<<SYNAPSE_WORKSPACE_NAME>>"
    [${SPARK_POOL_NAME}]="<<SPARK_POOL_NAME>>"
)

# Notebooks command has an 'export' feature - if you use 'show' it returns incompatible json
echo "Pulling notebooks"
az synapse notebook export \
    --workspace-name "${SYNAPSE_WORKSPACE_NAME}" \
    --output-folder "${DIR}/../synapse/notebook" \
    > /dev/null

for artifact in "${DIR}/../synapse/notebook"/*; do
    echo "Cleaning output and state for ${artifact}"
    # Please be careful of trying to optimise this into a single line,
    # you could end up with blank documents.
    cleaned_notebook=$(cat "${artifact}" | jq -S 'del(.cells[].outputs, .cells[].execution_count, .metadata.synapse_widget, .metadata.save_output)')
    # Replace tokens
    for token in "${!REPLACE_TOKENS[@]}"
    do
        cleaned_notebook="${cleaned_notebook//"$token"/"${REPLACE_TOKENS[$token]}"}"
    done
    echo "${cleaned_notebook}" > "${artifact}"
done

pullArtifacts() {
    # Iterate over the specified artifact types
    for artifact_type in ${ARTIFACT_TYPES[@]}; do
        file_extension="json"
        echo "Pulling ${artifact_type}s..."

        OLD_IFS="$IFS"
        IFS=$'\n' #alters how the bash array is read, to allow for spaces in synapse artifact names

        ARTIFACTS=$(az synapse ${artifact_type} list --workspace-name "${SYNAPSE_WORKSPACE_NAME}" --query []."name" -o tsv)

        for artifact in ${ARTIFACTS[@]}; do
            echo "Pulling ${artifact}..."
            
            ue_artifact=$(jq -rn --arg x $artifact '$x|@uri')
            artifact_json=$(curl -H "Content-Type: application/json" -H "Authorization: Bearer ${bearer}" ${SYNAPSE_WORKSPACE_ENDPOINT}/${artifact_type}s/${ue_artifact}?api-version=2020-12-01)

            # Replace tokens
            for token in "${!REPLACE_TOKENS[@]}"
            do
                artifact_json="${artifact_json//"$token"/"${REPLACE_TOKENS[$token]}"}"
            done

            if [[ "${artifact_type}" == "pipeline" ]]; then
                echo ${artifact_json} | jq -S "del(.etag, .id, .resourceGroup, .properties.lastPublishTime)" > "${DIR}/../synapse/${artifact_type}/${artifact}.${file_extension}"
            elif [[ "${artifact_type}" == "dataset" ]]; then
                echo ${artifact_json} | jq -S "del(.etag, .id, .resourceGroup, .properties.linkedServiceName.parameters)" > "${DIR}/../synapse/${artifact_type}/${artifact}.${file_extension}"
            else
                echo ${artifact_json} | jq -S "del(.etag, .id, .name, .resourceGroup, .type)" > "${DIR}/../synapse/${artifact_type}/${artifact}.${file_extension}"
            fi
        done
        IFS="$OLD_IFS" #set the pattern back before moving on to the next script
    done
}

#get auth token for REST APIs
bearer=$(az account get-access-token --resource https://dev.azuresynapse.net --query accessToken --output tsv) 

ARTIFACT_TYPES=("trigger")
pullArtifacts
ARTIFACT_TYPES=("pipeline")
pullArtifacts
ARTIFACT_TYPES=("dataset")
pullArtifacts