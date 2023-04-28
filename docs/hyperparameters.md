# Tuning hyperparameters for your data

The e-IAD Accelerator, exposes several hyperparameters and operational parameters via the Azure Synapse pipeline to made adjusting them easy.

## Hyperparameters

The hyperparameters for the e-IAD Accelerator have been defaulted to values that work with our [Large Synthetic Dataset](https://wwpsexternaldatastore.blob.core.windows.net/eiad/eIAD_Synthetic_Dataset_100M.zip?sp=r&st=2022-10-20T18:38:11Z&se=2025-10-21T02:38:11Z&spr=https&sv=2021-06-08&sr=b&sig=cuxVHDTIya20clF5ZWH%2F0L0fMNpzIYdEMmaHsuDifq8%3D). Please review these parameters carefully for your own data as they will have an impact on performance and quality of the data science portions of the pipeline.

Parameter | Default | Description
---|---|---
allowed_null_pct | 0.051 | The maximum percentage of null values that are allowed in a feature for it to be considered for anomaly detection.
date_feat | issued_date | The primary datetime field to be use for date-based features
depth_of_supply_chain_max_iter | 10 | The maximum depth of supply chain interactions to traverse before moving on to the next issuer or receiver. Increasing this value has a significant impact on performance due to the time it takes to traverse each degree of depth in the supply chain. It is recommended to increase the Azure Synapse Spark Pool capacity as well as the Azure Synapse notebook executor configurations before increasing this value.
id_feat | issuer_id_indexed,issued_date | The field containing the column names of features that are used for identification in the anomaly detection pipeline, but not included as features in the iJungle
id_feat_types | int,timestamp | The field containing the data types of features that are used for identification in the anomaly detection pipeline, but not included as features in the iJungle
number_of_interpret_features | 10 |  The number of individual features with feature importance scores from anomaly detection. Remaining features will get aggregated into a single score.
overhead_size | 0.001 | The percentage of data to sample from the full dataset to use for scoring the Isolation Forest models in determining the best Isolation Forest for your data. Use caution when increasing this value as the amount of data used will have significant performance impacts. Our testing recommends this value be less than 10M records for the Accelerator.
score_threshold | -0.75 | The maximum score that will be considered anomalous. Entries that score above this threshold will not be evaluated for feature importance. Lowering this threshold will decrease compute time for notebook 5_6_ijungle_predict_interpret.
seed | 42 | The seed used to start the random number generator used by the Isolation Forest algorithm.
subsample_list | 4096,2048,1024,512 | The list of the different subsample amounts used to train the Isolation Forests in the iJungle. These values can be modified, but only during research and development.
time_slice_list | by_day,by_week,by_month,by_quarter,by_year | These are the chronological groupings that the data can be evaluated across. Different feature aggregations, isolation forests, and anomaly detections will occur across each grouping. Allowed values are by_hour, by_day, by_week, by_month, by_quarter, by_year. Caution using by_hour and by_day on large sets of data as they can have a significant performance impact.
train_size | 0.001 | The percentage of data to sample for training the many different Isolation Forests against. Use caution when increasing this value as the amount of data used will have significant performance impacts. Our testing recommends this value be less than 10M records for the Accelerator
trees_list | 500,100,20,10 | The list of the different tree amounts used by the Isolation Forests in the iJungle. These values can be modified, but only during research and development.

## Operational Parameters

Parameter | Default | Description
---|---|---
data_encoding | latin-1 | The default encoding of the input data files. In ISO format.
data_quality_max_eval_date | 31-12-2021 | The expected max date for e-Invoicing data in the target batch. This will be used for Quality Index calculations. In the format dd-MM-YYYY.
data_quality_min_eval_date | 01-01-2021 | The expected max date for e-Invoicing data in the target batch. This will be used for Quality Index calculations. In the format dd-MM-YYYY.
data_separator | , | The separator character used in the CSV files.
drop_records_threshold | 0.01 | The percentage of null values to be allowed to remain in the data when cleaning the e-Invoicing data. If the percentage of null values exceed this percentage they will be dropped from the e-Invoicing data during data cleansing.
exchange_rates_file_name | exchange_rates.csv | The name of the exchange rate file in the exchange_rate folder.
first_year | 1950 | The minimum year of which any data should be valid. Any records with issued_date before this date will be dropped.
input_container_name | input | The name of the input container in the Azure Storage Account.
input_folder_name | *blank* | The name or path of parent folders in the input container that stores the exchange_rate, invoice, and taxpayer data. This can be used to run separate batches of data. See [Data Upload Specifications](datauploadspec.md) for more info.
local_currency_iso_code | EUR | The currency code of the e-Invoicing data in ISO format.
model_container_name | model | The name of the container where the best Isolation Forest models will be saved on the Azure Storage Account.
output_container_name | output | The name of the container where final UX ready output files will be saved on the Azure Storage Account
storage_account | eiaddataxxxxx.dfs.core.windows.net | The fully qualified name of the Azure Storage Account.
taxpayer_profile_file_name | tax_payer_profile.csv | The name of the taxpayer profile data file in the taxpayer folder.
working_container_name | working | The name of the container where intermediary working files will be saved on the Azure Storage Account.
