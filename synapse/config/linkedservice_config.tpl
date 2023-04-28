{
    "name": "keyvault",
    "type": "Microsoft.Synapse/workspaces/linkedservices",
    "properties": {
        "type": "AzureKeyVault",
        "typeProperties": {
            "baseUrl": "${keyvault_uri}"
        },
        "annotations": []
    }
}