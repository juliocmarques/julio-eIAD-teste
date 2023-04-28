# Configure Local Development Environment

Follow these steps to get the accelerator up and running in a subscription of your choice.

## Clone Repo

The first step will be to clone the Git repo into your Ubuntu 20.04 WSL environment. To do this:

>1. In GitHub, on the Source Tab select **<> Code** and get the HTTPS Clone path.
>2. Launch VSCode. Open the Ubunut 20.04(WSL) Terminal.
>3. Make sure you are in the root folder by running the following command from the bash command prompt
>
>   ``` bash
>      cd ~
>   ```
>
>4. Run the following command from the bash command prompt
>
>   ``` bash
>       git clone <repo url> eIAD
>   ```
>

This will now have created the **eIAD** folder on your Ubuntu 20.04 WSL environemnt.

## Open Code in Development Container

The next step is to open the source code and build the dev container. To do this you will:

1. Log into Azure using the Azure CLI
2. Open the cloned source code into VSCode
3. Launch and connect to the development contianer from VSCode

### Log into Azure using the Azure CLI

---

We will use the bash prompt from the previous step to issue the following commands:

``` bash
    az login
```

This will launch a browser session where you can complete you login.

Next from the bash prompt run:

``` bash
    az account show
```

The output here should show that you're logged into the intended Azure subscription.  If this isn't showing the right subscription then you can list all the subscriptions you have access to with:

``` bash
    az account list
```

From this output, grab the Subscription ID of the subscription you intend to deploy to and run:

``` bash
    az account set --subscription mysubscription
```

### Open the cloned source code into VSCode

---

Next, open the folder in VS Code by running the following commands:

``` bash
    cd eIAD
    code .
```

This will navigate into the eIAD folder and open a new VSCode window focused on that folder.

### Launch and connect to the development contianer from VSCode

---

As the new VSCode window opens you may notice a dialog in the lower right corner that indicates there is a development contiainer in the source location. Click on the **Reopen in Container** button.

![image](images%2Fvscode_reopen_in_container.png)

Don't worry if you miss the dialog, we can also do this from the Command Pallete in VS Code. Launch the Command Pallete from **View > Command Pallete** or **Ctrl+Shift+P**. From the Command Pallete prompt enter **Remote-Contianers: Reopen in Container**

VSCode will reload and you will see a new dialog in the lower right corner indicating it is building the dev contianer.

![image](images%2Fvscode_starting_dev_container.png)

You can click the **show log** link to see the output of the docker build that is running. This step can take a while as it will download and install all the necessary component for the e-IAD Accelerator to build and deploy properly. Once this is complete you will have a docker container named "eIAD" in Docker Desktop on your developer workstation.

*If dev containers are new to you, take a minute and see what they are [here](https://code.visualstudio.com/docs/remote/containers).*

---

## Configure Dev Container and ENV files

Now that the Dev Container is running, we need to set up your local environment variables. Open `scripts/environments` and copy `local.env.example` to `local.env`.

Open `local.env` and update values as needed:

Variable | Required | Description
--- | --- | ---
TF_VAR_location | Yes | The location (West Europe is the default). All Terraform and ARM templates should use this value.
WORKSPACE | Yes  | The workspace name (use something simple and unique to you). This will appended to eaid-????? in your subscription.
TF_VAR_is_local | Yes  | Defaults to true, **DO NOT** change this.
TF_VAR_resource_group_contributors | No  | Add the IDs of Active Directory security groups or users here to have them added as a Contributor to the created resoruce group and Azure services.
TF_VAR_azuread_object_owners | No | Add the IDs of Azure Active Directory users to have them added as Owner on all Azure Active Directory Enterprise Applicatoins and Application Registrations created by the deployment of e-IAD, version 1.0.
SYNAPSE_CUSTOM_PACKAGE_CONTAINER<br>SYNAPSE_CUSTOM_PACKAGE_CONTAINER_SAS<br>SYNAPSE_CUSTOM_PACKAGE_DIR | No | These parameters can be used to specify an Azure Storage Account URL that would allow custom packages (WHL, JAR, etc.) to be loaded into e-IAD, version 1.0, and automatically installed in the Apache Spark pool for Azure Synpase Analytics. e-IAD, version 1.0, does not use any custom packages currently.
PRIMARY_PIPELINE_NAME | Yes | Defaults to "e_IAD_synapse_pipe_main_data_load". This is the name of the Azure Syanpse Pipeline that will be started when running functional tests.

---

At this point this step is complete, please return to the [checklist](../#deployment) and complete the next step.
