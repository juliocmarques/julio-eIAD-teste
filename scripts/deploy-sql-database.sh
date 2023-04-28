#!/bin/bash

set -e

# Get the directory that this script is in
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# Get env vars for workspace from Terraform outputs
source "${DIR}/environments/infrastructure.env"

# load env vars
source "${DIR}/load-env.sh"

figlet Deploy SQL Database

# This is called if we are in a CI system and we will login
# with a Service Principal.
if [[ -n "${TF_IN_AUTOMATION}" ]]; then
    az login --service-principal -u "$ARM_CLIENT_ID" -p "$ARM_CLIENT_SECRET" --tenant "$ARM_TENANT_ID"
    az account set -s "$ARM_SUBSCRIPTION_ID"
fi

sqldbcount=$(sqlcmd -S $SYNAPSE_SQL_SERVERLESS_ENDPOINT -d master -U $SYNAPSE_SQL_USERNAME -P "$SYNAPSE_SQL_PASSWORD" -Q "SET NOCOUNT ON; DECLARE @result int; SELECT @result = COUNT(0) from sys.databases WHERE name = 'eiad'; PRINT @result" -I)
if [ $sqldbcount == "0" ]; then
    while [ $sqldbcount == "0" ]; do
        echo "Creating database 'eiad'"
        sqlcmd -S $SYNAPSE_SQL_SERVERLESS_ENDPOINT -d master -U $SYNAPSE_SQL_USERNAME -P "$SYNAPSE_SQL_PASSWORD" -I -Q "CREATE DATABASE eiad"

        #test for database successfully created
        echo "Verifying databse 'eiad' was created successfully"
        sqldbcount=$(sqlcmd -S $SYNAPSE_SQL_SERVERLESS_ENDPOINT -d master -U $SYNAPSE_SQL_USERNAME -P "$SYNAPSE_SQL_PASSWORD" -Q "SET NOCOUNT ON; DECLARE @result int; SELECT @result = COUNT(0) from sys.databases WHERE name = 'eiad'; PRINT @result" -I)
    done
    echo "Database 'eiad' created successfully"    
else
    echo "Database 'eiad' already exists"
fi

echo "Creating master key on database 'eiad'"
sqlcmd -S $SYNAPSE_SQL_SERVERLESS_ENDPOINT -d eiad -U $SYNAPSE_SQL_USERNAME -P "$SYNAPSE_SQL_PASSWORD" -I -Q "IF NOT EXISTS( SELECT name FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##') CREATE MASTER KEY ENCRYPTION BY PASSWORD = '$SYNAPSE_SQL_PASSWORD'"

echo "Creating database scoped credential for storage account"
sqlcmd -S $SYNAPSE_SQL_SERVERLESS_ENDPOINT -d eiad -U $SYNAPSE_SQL_USERNAME -P "$SYNAPSE_SQL_PASSWORD" -I -Q "IF NOT EXISTS( SELECT name FROM sys.database_scoped_credentials WHERE name = 'eiad_adls_sas') CREATE DATABASE SCOPED CREDENTIAL [eiad_adls_sas] WITH IDENTITY = 'SHARED ACCESS SIGNATURE', SECRET = '${STORAGE_ACCOUNT_SAS:1}';"

echo "Creating external file format for CSV files"
sqlcmd -S $SYNAPSE_SQL_SERVERLESS_ENDPOINT -d eiad -U $SYNAPSE_SQL_USERNAME -P "$SYNAPSE_SQL_PASSWORD" -I -Q "IF NOT EXISTS( SELECT name FROM sys.external_file_formats WHERE name = 'SynapseDelimitedTextFormat') CREATE EXTERNAL FILE FORMAT [SynapseDelimitedTextFormat] WITH ( FORMAT_TYPE = DELIMITEDTEXT , FORMAT_OPTIONS (FIELD_TERMINATOR = ',', USE_TYPE_DEFAULT = FALSE, FIRST_ROW = 2));"

echo "Creating external file format for parquet files"
sqlcmd -S $SYNAPSE_SQL_SERVERLESS_ENDPOINT -d eiad -U $SYNAPSE_SQL_USERNAME -P "$SYNAPSE_SQL_PASSWORD" -I -Q "IF NOT EXISTS( SELECT name FROM sys.external_file_formats WHERE name = 'SynapseParquetFormat') CREATE EXTERNAL FILE FORMAT [SynapseParquetFormat] WITH ( FORMAT_TYPE = PARQUET);"

echo "Creating external data source"
sqlcmd -S $SYNAPSE_SQL_SERVERLESS_ENDPOINT -d eiad -U $SYNAPSE_SQL_USERNAME -P "$SYNAPSE_SQL_PASSWORD" -I -Q "IF NOT EXISTS( SELECT name FROM sys.external_data_sources WHERE name = 'output_${STORAGE_ACCOUNT_NAME}_dfs_core_windows_net') CREATE EXTERNAL DATA SOURCE output_${STORAGE_ACCOUNT_NAME}_dfs_core_windows_net WITH ( LOCATION = 'abfss://output@${STORAGE_ACCOUNT_NAME}.dfs.core.windows.net', CREDENTIAL = eiad_adls_sas );"