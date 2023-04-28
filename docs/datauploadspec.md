# Data upload schema for e-IAD, version 1.0

The e-IAD Accelerator requires the data to follow a naming convention and be in a specific folder structure to be loaded by the processing pipelines in Azure Synapse.

All data must be uploaded to the Azure Storage Account in the resource group you deployed the accelerator to, with a name like "eiaddataxxxxx".

Within the Storage Account you will find the following containers:

Name | Purpose
---|---
input | Where data is uploaded to be processed by the pipelines.
model | Where the best Isolation Forest model will be output after running the pipeline
output | Where the data that is ready to used for visualizations is output from the pipeline
synapse | Where Azure Synapse stores internal working files. **DO NOT MODIFY**
working | Where intermediary files that are used during the pipeline are stored. These can be useful when investigating errors in the pipeline.

## Uploading data

To upload data to the e-IAD Accelerator, we will focus on the "input" container. When uploading the data it must be in folder structures that the pipeline expects. This structure is:

- exchange_rate
  - exchange_rates.csv
- invoice
  - one or more e-Invoicing ZIP files (see naming convention below)
- taxpayer
  - tax_payer_profile.csv

## e-Invoicing File Naming convention

The e-Invoicing files need to be CSV and in a compressed ZIP file. Both the CSV and ZIP file should be named like:

    DS-BIZS-MM-YYYY-desc

Example: **SYNTH-EINV-06-2021-LOAD**

Where:

>DS = Dataset
>
>BIZS = Business Source according to [Table 1: Business Data Source Code Convention for e-IAD](#table-1-business-data-source-code-convention-for-e-iad)
>
>MM = Month Number (two digit month or "00" for entire year)
>
>YYYY = Year
>
>desc = free form text description, without any dashes (-)

### Table 1: Business Data Source Code Convention for e-IAD

| Business Source | Abbreviation |
|--|--|
|Electronic Invoicing |EINV |
|Monthly Income Tax Declaration |TMIN |
|Monthly VAT Tax Declaration |TMVA |
|Annual Income Tax Declaration |TAIN |
|Annual VAT Tax Declaration |TAVA |
|Registration Records  |TREG  |
|Company Information |TCOM

## Uploading multiple batches at the same time

The e-IAD Accelerator does allow for uploading the folder structure and files specified above into separate parent folders to group sets of data into *batches*. This can be any set of folders you like as long as the lowest set of folders match the above specification.

The parent folder paths can be used in the pipeline as the "input_folder_name" parameter to focus the pipeline run on a single *batch* of data.

For example, you could input "batch1" into the pipeline parameter to run only the data inside the batch1 folder, or you could input "batch2/Q1" to only run the data in that folder.

- batch1
  - exchange_rate
    - exchange_rates.csv
  - invoice
    - one or more e-Invoicing files (see naming convention below)
  - taxpayer
    - tax_payer_profile.csv
- batch2
  - Q1
    - exchange_rate
      - exchange_rates.csv
    - invoice
      - one or more e-Invoicing files (see naming convention below)
    - taxpayer
      - tax_payer_profile.csv
  - Q2
    - exchange_rate
      - exchange_rates.csv
    - invoice
      - one or more e-Invoicing files (see naming convention below)
    - taxpayer
      - tax_payer_profile.csv
  - Q3
    - exchange_rate
      - exchange_rates.csv
    - invoice
      - one or more e-Invoicing files (see naming convention below)
    - taxpayer
      - tax_payer_profile.csv
