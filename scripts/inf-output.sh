#!/bin/bash
set -e

figlet Infrastructure Output

# This is called if we are in a CI system and we will login
# with a Service Principal.
if [ -n "${TF_IN_AUTOMATION}" ]
then
    az login --identity
fi

# Get the directory that this script is in
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${DIR}/load-env.sh
pushd "$DIR/../infrastructure/" > /dev/null

# Initialise Terraform with the correct path
${DIR}/terraform-init.sh "$DIR/../infrastructure/"

# Push outputs to a global json file, and for integration tests
terraform output -json > "$DIR/../inf_output.json"
