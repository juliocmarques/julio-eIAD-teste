#!/bin/bash
set -e

figlet Infrastructure

# Get the directory that this script is in
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "${DIR}/load-env.sh"
pushd "$DIR/../infrastructure" > /dev/null

# reset the current directory on exit using a trap so that the directory is reset even on error
function finish {
  popd > /dev/null
}
trap finish EXIT

# Initialise Terraform with the correct path
${DIR}/terraform-init.sh "$DIR/../infrastructure/"

${DIR}/terraform-plan-apply.sh -d "$DIR/../infrastructure" -p "eiad" -o "$DIR/../inf_output.json"