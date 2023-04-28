#!/bin/bash
set -e

echo "# Generated environment variables from tf output"

jq -r '
    [
        {
            "path": "storage_account_id",
            "env_var": "STORAGE_ACCOUNT_ID"
        },
        {
            "path": "storage_account_name",
            "env_var": "STORAGE_ACCOUNT_NAME"
        },
        {
            "path": "storage_account_key",
            "env_var": "STORAGE_ACCOUNT_KEY"
        },   
        {
            "path": "storage_account_connection_string",
            "env_var": "STORAGE_ACCOUNT_CONNECTION_STRING"
        },        
        {
            "path": "key_vault_name",
            "env_var": "KEY_VAULT_NAME"
        },
        {
            "path": "resource_group_name",
            "env_var": "RESOURCE_GROUP"
        },
        {
            "path": "spark_pool_name",
            "env_var": "SPARK_POOL_NAME"
        },
        {
            "path": "synapse_workspace_id",
            "env_var": "SYNAPSE_WORKSPACE_ID"
        },
        {
            "path": "synapse_workspace_name",
            "env_var": "SYNAPSE_WORKSPACE_NAME"
        },
        {
            "path": "synapse_workspace_endpoint",
            "env_var": "SYNAPSE_WORKSPACE_ENDPOINT"
        },
        {
            "path": "subscription_id",
            "env_var": "SUBSCRIPTION_ID"
        },
        {
            "path": "azure_monitor_workspace_id",
            "env_var": "AZURE_MONITOR_WORKSPACE_ID"
        },
        {
            "path": "synapse_spark_node_count",
            "env_var": "SYNAPSE_SPARK_NODE_COUNT"
        },
        {
            "path": "location",
            "env_var": "LOCATION"
        },
        {
            "path": "synapse_sql_serverless_endpoint",
            "env_var": "SYNAPSE_SQL_SERVERLESS_ENDPOINT"
        },
        {
            "path": "synapse_sql_username",
            "env_var": "SYNAPSE_SQL_USERNAME"
        },
        {
            "path": "synapse_sql_password",
            "env_var": "SYNAPSE_SQL_PASSWORD"
        },
        {
            "path": "storage_account_sas",
            "env_var": "STORAGE_ACCOUNT_SAS"
        }
    ]
        as $env_vars_to_extract
    |
    with_entries(
        select (
            .key as $a
            |
            any( $env_vars_to_extract[]; .path == $a)
        )
        |
        .key |= . as $old_key | ($env_vars_to_extract[] | select (.path == $old_key) | .env_var)
    )
    |
    to_entries
    | 
    map("export \(.key)=\"\(.value.value)\"")
    |
    .[]
    ' | sed "s/\"/'/g" # replace double quote with single quote to handle special chars