#!/bin/bash
set -e

figlet Functional Tests

# Get the directory that this script is in - move to tests dir
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
pushd "$DIR/../tests" > /dev/null

# Get env vars for workspace from Terraform outputs
source "${DIR}/environments/infrastructure.env"
source "${DIR}/load-env.sh"

# This is called if we are in a CI system and we will login
# with a Service Principal.
if [ -n "${TF_IN_AUTOMATION}" ]
then
    az login --service-principal -u "$ARM_CLIENT_ID" -p "$ARM_CLIENT_SECRET" --tenant "$ARM_TENANT_ID"
    az account set -s "$ARM_SUBSCRIPTION_ID"
fi

rm -rf ./output
mkdir -p ./output
echo '*' > ./output/.gitignore

# Install requirements
pip install -r requirements.txt --disable-pip-version-check -q

# Pipeline functional test
python run_tests.py \
    --test_type functional \
    --pipeline_name "${PRIMARY_PIPELINE_NAME}" \
    --storage_name "${STORAGE_ACCOUNT_NAME}" \
    --storage_key "${STORAGE_ACCOUNT_KEY}" \
    --synapse_endpoint "${SYNAPSE_WORKSPACE_ENDPOINT}" \
    --synapse_parameters '{"depth_of_supply_chain_max_iter":10,"score_threshold":"0.5","overhead_size":"0.5","train_size":"0.5","time_slice_list":"by_hour,by_day,by_week,by_month,by_quarter,by_year","input_folder_name":"functional_tests"}' \
    --test_data_dir functional_tests \
    --disable_cleanup "${DISABLE_TEST_CLEANUP}" \
    --ignore_synapse_query "${IGNORE_TEST_PIPELINE_QUERY}"