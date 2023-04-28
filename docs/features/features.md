# e-IAD, version 1.0, Features

- [Data Engineering Pipeline](#data-engineering-pipeline)
  - [Data Loading and Statistics](#data-loading-and-statistics)
  - [Data Quality Index](#data-quality-index)
  - [Data Cleansing](#data-cleansing)
- [Data Science Pipeline](#data-science-pipeline)
  - [Feature Engineering and Graph Analysis](#feature-engineering-and-graph-analysis)
  - [Anomaly Detection](#anomaly-detection)
- [Primary UX (Power BI)](#primary-ux-power-bi)

The primary features of the e-IAD Accelerator are an Azure Synapse processing pipeline that consists of two major parts:

- A Data Engineering pipeline that prepares the data for Anomaly Detection
- A Data Science Pipeline that analyzes the data using AI to detect anomalies.

And a User Experience (UX) to view the results of the processing pipeline in Power BI.

## Data Engineering Pipeline

The Data Engineering pipeline orchestrates the loading, decompressing, schema validation, statistic checks, quality index calculation, and data cleansing to prepare the data so that the data is prepared and in the best possible condition for the Data Science portion of the pipeline.

More information on the Data Engineering Pipeline can be found [here](data_engineering_pipeline.md)

### Data Loading and Statistics

One part of the overall Data Engineering portion of the pipeline is to load, decompress, validate the schema, and perform statistic calculations on the data.

For a detailed overview of this part of the pipeline go [here](data_loading_and_stats.md)

### Data Quality Index

Another part of the overall Data Engineering portion of the pipeline is to try to calculate specific quality metrics for key fields as well as an aggregate quality index score for the overall dataset.

More information on the Quality Index specification can be found [here](quality_index.md)

### Data Cleansing

The final part of the overall Data Engineering portion of the pipeline is data cleansing that ensures valid values and/or moniker values are in place in the dataset to ensure the Data Science portion of the pipeline can run without having to worry about invalid data.

More information on the Data Cleansing specification can be found [here](data_cleansing.md)

## Data Science Pipeline

The Data Science pipeline transforms cleaned data into features suitable for anomaly detection, trains iJungle unsupervised anomaly detection models and calculates which data points are anomalous.

More information on the Data Science Pipeline can be found [here](data_science_pipeline.md)

### Feature Engineering and Graph Analysis

The first part of the overall Data Science portion of the pipeline is designed to extract features related to time periods, ratios, SME suggestions, and the network of transactions.

For more information on Feature Engineering and Graph Analysis go [here](feat_eng_and_graph_analysis.md)

### Anomaly Detection

The second part of the overall Data Science portion of the pipeline is designed to use an unsupervised AI method, iJungle, to identify the most representative Isolation Forest for the data and then measure an anomaly score and contribution amounts from the features extracted from the data.

For more information on the Anomaly Detection portion go [here](anomaly_detection.md)

## Primary UX (Power BI)

The Primary UX for the e-IAD Accelerator is based on Power BI. A detailed Power BI report is provided to help view and analyze the output data files from the Azure Synapse processing pipeline.

More information on the Power BI report can be found [here](powerbi_features.md)
