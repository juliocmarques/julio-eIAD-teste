# Data Cleansing

Data Cleansing is the last stage in the Data Engineering Pipeline for the e-IAD Accelerator. This stage is critical to ensure the data has consistency without gaps and invalid values to enable a successful run of the data science pipeline.

Both the e-Invoicing data files and the taxpayer profile data file are cleansed using the following set of rules:

## e-Invoicing Cleansing Specification

Entity | Field | Cleansing Action
---|---|---
|Issuer  |issuer_type  | Replace NULL values with string literal "NT".
|Issuer  |issuer_id  | Drop records if < "drop_records_threshold" hyper-parameter (defaulted to 1%).
|Issuer  |activity_issuer  | Replace NULL values, values > 8 characters, and values < 4 characters with "999999".
|Receiver  |receiver_type  | Replace NULL values with string literal "NT".
|Receiver  |receiver_id  | Replace NULL values or values > 16 characters with string literal "no_identified_receiver".
| Document  | document_type  | Replace NULL values with string literal "I".
|Document  |document_id  | Replace NULL values with string literal "no_identified_document".
|Document  |issued_date  | Drop records if < "drop_records_threshold" hyper-parameter (defaulted to 1%).
|Document  |sales_terms  | Replace NULL values with string literal "00".
|Document  |credit_term  | Replace NULL values with string literal "00".
|Document  |currency  | Replace NULL values with "local_currency_iso_code" hyper-parameter (defaulted to "EUR").
|Document  |exchange_rate_r  | Replace NULL values with "1.0" Float value.
|Document  |payment_method1  | Replace NULL values or values > 2 characters with string literal "00".
|Document  |payment_method2  | Replace NULL values or values > 2 characters with string literal "00".
|Document  |payment_method3  | Replace NULL values or values > 2 characters with string literal "00".
|Document  |payment_method4  | Replace NULL values or values > 2 characters with string literal "00".
|Document  |payment_method5  | Replace NULL values or values > 2 characters with string literal "00".
|Document  |payment_method99  | Replace NULL values or values > 2 characters with string literal "00".
|Transaction  |total_taxable_services  | Replace NULL values with "0.0" Float value.
|Transaction  |total_non_taxable_services  | Replace NULL values with "0.0" Float value.
|Transaction  |total_taxable_goods  | Replace NULL values with "0.0" Float value.
|Transaction  |total_non_taxable_goods  | Replace NULL values with "0.0" Float value.
|Transaction  |total_taxable  | Replace NULL values with "0.0" Float value.
|Transaction  |total_non_taxable  | Replace NULL values with "0.0" Float value.
|Transaction  |total_sales  | Replace NULL values with "0.0" Float value.
|Transaction  |total_discounts  | Replace NULL values with "0.0" Float value.
|Transaction  |total_voucher  | Drop records if < "drop_records_threshold" hyper-parameter (defaulted to 1%). Else, replace NULL values with "0.0" Float value.
|Transaction  |total_tax  | Drop records if < "drop_records_threshold" hyper-parameter (defaulted to 1%). Else, replace NULL values with "0.0" Float value.

## Taxpayer Profile Cleansing Specification

Field | Cleansing Action
---|---
taxpayer_id | Drop records with NULL values. Drop duplicated records. Delete first record when duplicate|
taxpayer_type | Replace Nulls with string literal "no_taxpayer_type".
fiscal_condition | Replace Nulls with string literal "no_fiscal_condition".
regime_name | Replace Nulls with string literal "no_regime_name".
taxpayer_size | Replace Nulls with string literal "no_taxpayer_size".
main_activity | Replace Nulls with value "999999".
sec1_activity | Replace Nulls with value "999999".
sec2_activity | Replace Nulls with value "999999".
employees_number | Replace Nulls with integer "1".
legal_reg_date | Replace Nulls with "1900-1-1".
tax_reg_date | Replace Nulls with "1900-1-1".
e_inv_enroll_date | Replace Nulls with "1900-1-1".
reported_assets  | Replace Nulls with value "0".
total_capital  | Replace Nulls with Float Number "1.0".
social_capital  | Replace Nulls with Float Number "1.0".
total_assets | Replace Nulls with Float Number "1.0"
total_fixed_assets | Replace Nulls with Float Number "1.0".
total_liabilities  | Replace Nulls with Float Number "1.0"
gross_income | Replace Nulls with Float Number "1.0".
net_income  | Replace Nulls with Float Number "1.0".
total_vat_sales  | Replace Nulls with Float Number "1.0".
credited_einvoicing_value | Replace Nulls with Float Number "1.0".
state  | Replace Nulls with code "00".
municipality | Replace Nulls with "000000" code.
city| Replace Nulls with "000000" code.
