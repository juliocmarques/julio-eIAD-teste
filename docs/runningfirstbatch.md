# Running your first batch

Before running your first batch, please be sure you have verified the following:

- [Input data schemas](inputdataschema.md)
- [Data is uploaded properly](datauploadspec.md)
- [Hyperparameters have been tuned for your dataset](hyperparameters.md)

Once the pre-requisites have been completed, you can proceed to the following steps to run the e-IAD Accelerator data processing pipelines for the first time.

**IMPORTANT**: We provide a [Large Synthetic Dataset](https://wwpsexternaldatastore.blob.core.windows.net/eiad/eIAD_Synthetic_Dataset_100M.zip?sp=r&st=2022-10-20T18:38:11Z&se=2025-10-21T02:38:11Z&spr=https&sv=2021-06-08&sr=b&sig=cuxVHDTIya20clF5ZWH%2F0L0fMNpzIYdEMmaHsuDifq8%3D) for testing the e-IAD Accelerator at scale.

## Launching Azure Synapse Studio

You must access the Azure Synapse Studio from the Azure Portal to be able to trigger the data processing pipeline for e-IAD Accelerator.

To open Azure Synapse Studio:

>1. Log into the Azure Portal (<https://portal.azure.com>)
>2. Navigate to the Resource Group that you deployed to. It should be named like, eaid-\<workspace\>.
>3. Find the resource of type "Synapse Workspace" and click on its name.
>4. One the Synapse Workspace blade opens in the portal, find and click **Open** in the Getting Started, Open Synapse Studio section.
>![Open Synapse Studio](images/OpenSynapseStudio.png)
>5. This will open Synapse Studio to the home page. You may be required to reauthenticate upon opening Synapse Studio.

## Triggering the data processing pipeline

Now that you are in Synapse Studio, let's familiarize ourselves with the left hand navigation panel.

![Synapse Studio Navigation](images/SynapseStuidioNav.png)

>1. To run the data processing pipelines we need to navigate to the Pipelines section.
>2. Once in the pipeline section you will see two pipelines provided by the e-IAD Accelerator.
>
>       ![e-IAD Accelerator Pipelines](images/eIAD_pipelines.png)
>3. Select the "e_IAD_synapse_pipe_main_data_load" and it will open the pipeline details.
>4. From the top of the pipeline details page, select **Add Trigger** > **Trigger Now**
>![Trigger Synapse pipeline](images/Trigger_pipeline.png)
>5. This will open the parameters panel for the pipeline. Here you will make any required adjustments from the Hyperparameter Tuning step to override the default values.
>![Pipeline parameters](images/Pipeline_parameters.png)
>6. Click **OK** to start the pipeline.

## Monitoring a running pipeline

The e-IAD Accelerator provides you two ways to monitor an active running Synapse pipeline. The first is in the Synapse Studio Monitoring section and the second is in an Azure Workbook configured to provide views over instrumentation and logging from the pipeline.

### Monitoring in Azure Studio

To monitor the pipeline in Synapse Studio, navigate to the Monitoring section.

From this section you can select **Pipeline Runs** and use the **Triggered** tab to see any active pipelines.

![Monitoring pipelines in Synapse Studio](images/Monitoring_from_Synapse_Studio.png)

### Monitoring in Azure Workbook

To monitor the pipeline from the Azure Workbook, you must navigate to the Azure Portal.

>1. Log into the Azure Portal (<https://portal.azure.com>)
>2. Navigate to the Resource Group that you deployed to. It should be named like, eaid-\<workspace\>.
>3. Find the resource of type "Azure Workbook" and click on its name.
Click the **Open Workbook** notebook.

The Azure workbook has several views to help with monitoring the pipeline.

Section | Purpose
---|---
Pipelines | This page shows instrumented sections of the code's performance measurements. It is grouped by "batch_num".
Application Logs | These are custom logs entries instrumented into the e-IAD Accelerator code.
Synapse Summary | This is view of the status and performance of the Synapse Spark environment per Spark Application.
Executors | This is an performance overview of the Spark driver and executors per Spark Application.
Synapse Logs | This is a view of the System logging produced by the Azure Synapse Workspace service.
Custom Metrics | We are not logging any custom metrics for e-IAD Accelerator at this time.

More information on the Azure Workbook and how to extend it can be found [here](../infrastructure/modules/monitor/README.md)
