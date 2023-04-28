# Transparency Note: Electronic-Invoicing Anomaly Detector (e-IAD)

Updated 4 November 2022

## Table of Contents

- [What is a Transparency Note?](#what-is-a-transparency-note)
- [The basics of e-IAD Accelerator](#the-basics-of-e-iad-accelerator)
  - [Introduction](#introduction)
  - [Key Terms](#key-terms)
- [Capabilities](#capabilities)
  - [System behavior](#system-behavior)
    - [Data Preparation](#data-preparation)
    - [Anomaly Detection](#anomaly-detection)
  - [Use Cases](#use-cases)
    - [Intended uses](#intended-uses)
    - [Considerations when choosing a use case](#considerations-when-choosing-a-use-case)
- [Limitations of e-IAD](#limitations-of-e-iad)
  - [Technical limitations, operational factors and ranges](#technical-limitations-operational-factors-and-ranges)
    - [Non-Production Status](#non-production-status)
    - [Non-Real Time Usage](#non-real-time-usage)
    - [Anomalous transactions](#anomalous-transactions)
    - [Feature extraction](#feature-extraction)
- [System Performance](#system-performance)
- [Evaluation of e-AID](#evaluation-of-e-iad)
  - [Evaluating and Integrating e-IAD for your use](#evaluating-and-integrating-e-iad-for-your-use)
    - [Human-in-the-loop](#human-in-the-loop)
    - [Data Quality Evaluation](#data-quality-evaluation)
    - [Model Training](#model-training)
    - [Evaluation of system performance](#evaluation-of-system-performance)
    - [Use technical documentation](#use-technical-documentation)
  - [Technical limitations, operational factors and ranges](#technical-limitations-operational-factors-and-ranges-1)
- [Learn more about responsible AI](#learn-more-about-responsible-ai)
- [Learn more about the e-IAD Accelerator](#learn-more-about-the-e-iad-accelerator)
- [Contact Us](#contact-us)

## What is a Transparency Note?

An AI system includes not only the technology, but also the people who will use it, the people who will be affected by it, and the environment in which it is deployed. Creating a system that is fit for its intended purpose requires an understanding of how the technology works, what its capabilities and limitations are, and how to achieve the best performance. Microsoft’s Transparency Notes are intended to help you understand how our AI technology works, the choices system owners can make that influence system performance and behavior, and the importance of thinking about the whole system, including the technology, the people, and the environment. You can use Transparency Notes when developing or deploying your own system, or share them with the people who will use or be affected by your system.

Microsoft’s Transparency Notes are part of a broader effort at Microsoft to put our AI Principles into practice. To find out more, see the [Microsoft AI principles](https://www.microsoft.com/ai/responsible-ai).

## The basics of e-IAD Accelerator

### Introduction

The e-IAD Accelerator is a system built on Azure that is intended to detect anomalies in trading behavior based on very large sets of Business-to-Business electronic invoicing data. e-IAD also provides key analytics reflecting the landscape of suppliers and customers, proportions and size, supply chain characteristics and a range of trading pattern information in the ecosystem.

The system relies on an open source machine learning project named [iJungle](https://github.com/microsoft/dstoolkit-anomaly-detection-ijungle), which implements a system for machine learning to train models to detect anomalies in very large datasets. This accelerator contains methods to import electronic invoicing data, process the data, train models to detect anomalies in the data, execute the trained models to detect anomalies, and report on the processing outcomes.

This system outputs information on the quality of the input data, information about the data’s structure, and information about anomalies found in the processed data.

This system **DOES NOT** identify fraud. Determination of fraud is made by humans who are trained and can apply rule of law. This system only identifies statistical anomalies in electronic invoicing data.

### Key Terms

Terminology | Definition
---|---
[Anomaly Detection](https://en.wikipedia.org/wiki/Anomaly_detection) | The process of detecting something that is different or abnormal. In the case of public finance data, anomalies may be simply anomalies and have no further meaning. Anomalies should not be conflated with fraud.
[Electronic invoicing](https://en.wikipedia.org/wiki/Electronic_invoicing) | Electronic methods used between trading partners to present and monitor financial transactions between one another. In many countries, electronic invoicing is mandatory for trade, and these invoices are shared with the public finance entity.
[Feature](https://en.wikipedia.org/wiki/Feature_(machine_learning)) | A measurable property or characteristic of a phenomenon. In this project, features are created to characterize the entities and behaviors of the entities related to electronic invoicing history.
[Fraud](https://en.wikipedia.org/wiki/Fraud) | Intentional deception. In the case of public finance, fraud is determined by review of evidence by trained auditors. Anomalies must not be conflated with fraud.
[iJungle](https://github.com/microsoft/dstoolkit-anomaly-detection-ijungle) | An open-source project which implements a system for machine learning to train models to detect anomalies in very large datasets.

## Capabilities

### System behavior

This system is implemented primarily on top of Azure Synapse with Azure Data Lake Services (ADLS Gen2) to identify anomalies in Business-to-Business electronic invoicing behavior based on electronic invoicing system data. e-AID is trained on very large amounts of transaction data, for example, the entire economic transaction data in a country for one or more years.

#### Data Preparation

Business (taxpayer) information and electronic invoicing data supplied in ADLS Gen2 is cleaned and prepared for anomaly detection via the iJungle toolkit. As part of the data processing, the system calculates additional features which are used alongside the raw data. These features are later used in the anomaly detection process.

#### Anomaly Detection

After the models are trained, they can be used to find anomalies in the data. The reports can be used to review the outcomes. These outcomes may include anomalies in the data, and those anomalies may be reviewed or investigated to determine the nature of the anomalies. Anomalies must not be presumed to be fraudulent activity.

### Use cases

#### Intended uses

This system is intended for the purpose of identifying anomalies in Business-to-Business electronic invoicing behavior. This is a use case for Public Finance institutions who are seeking to gain insight into their country’s economy or identify specific actors or behaviors which are anomalous as compared to the rest of the economy. This system may identify anomalies within the transactions that may not be visible through normal inspection due to the volume of data and time scale of transactions that occur (one or more years).

This system may additionally be used to understand relationships between business entities and quality of the economic data run through the system by leveraging the existing reporting.

#### Considerations when choosing a use case

Avoid using e-IAD with citizen or consumer transaction data. This system has only been approved for Business-to-Business interactions. This system has not been evaluated for, and is not designed for, anomaly detection with individual purchase behavior or transactions. Any use cases that seek to incorporate end consumer or citizen data should be carefully evaluated per Microsoft’s Responsible AI guidelines.

**Avoid using this system to detect fraud** or as a ‘fraud detector’. Anomalies in economic transactions do not correlate 1:1 with fraud, and it should not be assumed that identified anomalies are cases of fraud. Include a human reviewer who has been trained to determine if activities are fraudulent to review any anomalies detected by this system.

This system may be augmented by the user for additional anomaly detection use cases, such as different business transaction records and filings. Understanding of the meaning of what an anomaly is with new data or features extracted from the user data will be important for the implementing user.

## Limitations of e-IAD

In this section we describe several known limitations of the e-IAD system.

### Technical limitations, operational factors and ranges

#### Non-Production Status

This software is an accelerator codebase that is not configured for production use. Effort must be taken to ensure that appropriate data security practices are followed to be compliant with local regulations in alignment with the classification of data intended to be used with this system.

#### Non-Real Time Usage

This software is not intended for real-time data usage. This is a batch-processing system, intended for offline data analysis.  

#### Anomalous transactions

This system was not designed to detect anomalous business-to-business transactions, rather it identifies anomalous businesses based on the transaction data and the feature set that is extracted from the data input to the system.

#### Feature extraction

A core component to detecting anomalies are the features which are extracted from the data. These features are used as inputs to the anomaly detection. To improve anomaly detection, users of the system should understand their local economic drivers and policies and understand if additional features are desired to be considered for anomaly detection. These economic drivers and policies often include incentives, export or import policies, and other activities related directly to taxation. We advise careful consideration of the features with respect to your local policies and activities.

**This system has not been evaluated for its intended purpose against your data!** This system makes no claim for precision or accuracy. The behavior and performance of e-IAD depends on the type, volume and quality of electronic invoicing data ingested to it. This data will differ across countries, and therefore it is not possible to make a generic evaluation of e-IAD for your purposes.

## System performance

The central part of e-IAD (the system) is to produce anomaly detection capabilities at the company (business) level. The two primary outputs for anomaly detection are (a) the score of those results marked as an anomaly and (b) the list of features with their weights that influenced the score.

The system detects an anomaly at the company level for a summarized time period. Individual electronic invoicing transactions are not flagged as an anomaly.

The better the tax user establishes data segmentation criteria to filter out what they already knows to be irregular, the better the system will detect unknown irregular transactions in the invoicing data.

The system outcomes are evaluated as follows:
Outcomes | Examples
---|---
True positive |	- The company issues irregular e-Invoicing transactions in a period. <br>- The system detects irregular invoicing transactions. <br>- The outcome is an anomaly score detected.
False positive | - The company does not issue irregular e-Invoicing transactions in a period.<br>- The system detects irregular invoicing transactions. <br>- The outcome is an incorrect anomaly detected.
False Negative | - The company issues irregular e-Invoicing transactions in a period. <br>- The system does not detect irregular invoicing transactions. <br>- The outcome is an anomaly score that is not detected.
True Negative | - The company does not issue irregular e-Invoicing transactions in a period. <br>- The system does not detect irregular invoicing transactions. <br>- The outcome is an anomaly that is not detected.

Data with known anomalies should be used to evaluate the performance of the system. The synthetic data provided with the system may be used for this purpose. With real data it is suggested that humans verify outputs from the system to determine if they fit within one of the categories listed above.

## Evaluation of e-IAD

Microsoft and CIAT ([Inter-American Center of Tax Administrations](https://www.ciat.org/)) team members worked with the Government of Costa Rica to evaluate initial system output compared to known anomalies in a shared dataset from the year 2021 as well as anomalies in the sample datasets provided with this project.

Initial results from evaluation with the Government of Costa Rica have demonstrated the system’s effectiveness at detecting anomalous events. Future efforts will be conducted with CIAT member(s) to continue evaluation of this system via investigation of real customer data. This document will be updated over time as future evaluations are performed.

### Evaluating and Integrating e-IAD for your use

This section outlines best practices for using e-IAD responsibly to achieve best performance from the system.

#### Human-in-the-loop

Always include a human-in-the-loop to evaluate the results against your data. See Limitations section above.

#### Data Quality Evaluation

The supplied reports should be used to understand the quality of the input data. If the reports show that there are significant amounts of data cleanliness issues, the data should be investigated before attempting to investigate anomalies; low quality datasets should not be applied to a machine learning system.

#### Model Training

Once cleaned and valid data is confirmed, the iJungle toolkit is used to train models on a sample of the data. It is critical to train models on the supplied data as anomalies in economies may differ between countries and across timespans (especially when economic policies change). The models must be tuned for the specific data provided, and documentation provided on tuning this system should be reviewed before operating. It is also suggested that you review the documentation of iJungle (linked above).

#### Evaluation of system performance

The system outcomes need to be evaluated by the user to determine the accuracy of the system’s anomaly detection against the user’s data. Do not assume that the system is performing well with your data. Use the information about system performance listed above to understand the outcomes, both True and False.

#### Use technical documentation

The technical documentation provided with this system and the iJungle toolkit should be used when tuning the system to the best outcomes. Care should be used when tuning. Trade-offs between accuracy versus computational performance should be understood and stated explicitly when choices are made.

You can find the technical documentation on preparing your data and tuning the accelerator in our [Using e-IAD for the first time](../README.md#using-e-iad-for-the-first-time) section.

## Technical limitations, operational factors and ranges

**This system has not been evaluated for its intended purpose against your data!**

This system makes no claim for precision or accuracy. The behaviour and performance of e-IAD depends on the type, volume and quality of electronic invoicing data ingested to it. This data will differ across countries, and therefore it is not possible to make a generic evaluation of e-IAD for your purposes.

## Learn more about responsible AI

---

[Microsoft AI principles](https://www.microsoft.com/en-us/ai/responsible-ai)

[Microsoft responsible AI resources](https://www.microsoft.com/en-us/ai/responsible-ai-resources)

[Microsoft Azure Learning courses on responsible AI](https://docs.microsoft.com/en-us/learn/paths/responsible-ai-business-principles/)

## Learn more about the e-IAD Accelerator

---

[e-EIAD Accelerator](https://github.com/microsoft/eIAD)

[iJungle](https://github.com/microsoft/dstoolkit-anomaly-detection-ijungle)

## Contact us

Give us feedback on this document in our [Q&A Discussions](https://github.com/microsoft/eIAD/discussions/categories/q-a) on GitHub.

## About this document

© 2022 Microsoft Corporation. All rights reserved. This document is provided "as-is" and for informational purposes only. Information and views expressed in this document, including URL and other Internet Web site references, may change without notice. You bear the risk of using it. Some examples are for illustration only and are fictitious. No real association is intended or inferred.

Published: 04 Nov 2022
