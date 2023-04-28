# Known Issues

## Docker: Got permission denied while trying to connect to the Docker daemon socket

Got permission denied while trying to connect to the Docker daemon socket at ...
![docker_error_1.png](images/ki_docker_permission_error.png)

### Solution

Run the following command:

`$ sudo chmod 666 /var/run/docker.sock`

---

## Azure Key Vault - During make deploy error purging of Secret

This error is because you may be reusing an already used resource group name and Key Vault cannot delete the old keys.

![keyvault-error.png](images/ki_key_vault_purge_error.png)

### Solution

In your local.env file, use a new resource group name which is new and unique from previous ones or other possible used ones in the Subscription.

`export WORKSPACE="<put something new here>"`

---

## Error: autorest/azure: Service returned an error. Status=403 Code="AuthorizationPermissionMismatch" Message="This request is not authorized to perform this operation using this permission"

![Error_Authorization_Mismatch.png](images/ki_storage_auth_error.png)

### Solution

Assign "Storage Blob Data Contributor" role on the storage account created by eIAD with the name like "eiaddataxxxxx" to the user performing the deployment

---
