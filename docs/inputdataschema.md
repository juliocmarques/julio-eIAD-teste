# Input Data Schema for e-IAD, version 1.0

The e-IAD Accelerator requires three types of files to be prepared to enable the processing pipelines in Azure Synapse. These include

- e-Invoicing Data file(s) (**CSV**)
- Taxpayer Profile file (**CSV**)
- Exchange Rate file (**CSV**)

The following sections will detail the specification for each file type.

---

## e-Invoicing Data File(s)

ENTITY | FIELD NAME | TYPE  | LENGTH | DESCRIPTION
|--|--|--|--|--|
|Issuer  |issuer_type  |String |1 to 2  |String (alphanumeric) code to identify the type of taxpayer: Individuals, Businesses, Self-Employed, Charities and Non-profits, Individuals International, Businesses International, Government Liaison, etc. For the issuer_code it can be customized by the tax agency, but should be on the length and data type specifications.   |
|Issuer  |issuer_id  |String  |6 to 16  |Tax ID code (alphanumeric) associated with the taxpayer who issued the e-Invoicing. It is a unique value corresponding to the taxpayer_id in a taxpayer registration database. |
|Issuer  |activity_issuer  |String  |4 to 8  |String value (numeric value) that indicates the code of the economic activity to which the electronic receipt corresponds. The activity code should follow (recommended) the International Standard Industrial Classification of All Economic Activities (ISIC) defined by the United Nations. The code comprises three segments: Division, Group, and Class, equivalent to 4 digits. It is possible that countries add a layer and making to a 6 digit code. |
|Receiver  |receiver_type  |String  |1 to 2 |String (alphanumeric) code to identify the type of taxpayer: Individuals, Businesses, Self-Employed, Charities and Non-profits, Individuals International, Businesses International, Government Liaisons, etc. For the issuer_code it can be customized by the tax agency, but should be on the length and data type specifications.  |
|Receiver  |receiver_id  |String |6 to 16  |Tax ID code (alphanumeric) associated with the taxpayer who received the e-Invoicing. It is a unique value corresponding to the taxpayer_id in a taxpayer registration database. |
| Document  | document_type  | String  | 1 to 2  | String (alphanumeric) code that identifies the type of electronic voucher: I = Invoice, D = Debit Note, C = Credit Note, O = Order, P = Purchase, G = Goods certificate, T = Tender, X: Export Invoice, etc.<br/><br/>For reference: Peppol Code Lists - Document types: <https://docs.peppol.eu/edelivery/codelists/v8.0/Peppol%20Code%20Lists%20-%20Document%20types%20v8.0.html#:~:text=%20%20%20%20Num%23%20%20%20,%20%201.0.0%20%207%20more%20rows%20> <br/><br/> For reference: UBL 3.1 Documents at <https://docs.oasis-open.org/ubl/UBL-NDR/v3.1/cnd01/UBL-NDR-v3.1-cnd01.html>
|Document  |document_id  |String  |8 to 100  |8 to 100-character code that identifies the document ID. document_id is a unique value not possible to be duplicated |
|Document  |issued_date  |Date  |  |Date and time at which the voucher is issued in the format YYYY-MM-DD HH:MM:SS  |
|Document  |sales_terms  |String  |2 |Two digit code string with a numeric value. Terms of sale: 01 Cash, 02 Credit, 03 Consignment, 04 Parcel, 05 Lease with purchase option, 06 Lease in financial function, 07 Collection in favor of a third party, 08 services rendered to the state on credit, 09 payment of service rendered to the state, 99 Others  |
|Document  |credit_term  |Integer  |1 to 2 |Credit term in months - Integer value  |
|Document  |currency  |String  |3  |Currency code according to ISO 4217 <br/><br/> Reference: <https://en.wikipedia.org/wiki/ISO_4217>
|Document  |exchange_rate_r  |Float  |2 to 6  |National Central Bank reference sales exchange rate on the day of issuance of the voucher. Currency rate reported by issuer but not necessarily validated. Format: XX.YYYY. Example: 11.5867|
|Document  |payment_method1  |String  |2  |String value (alphanumeric or numeric) that corresponds to the means of payment used. Several types of payment methods are allowed simultaneously, but the proportion of each of them is not indicated: 01 Cash, 02 Card, 03 Check, 04 Transfer - bank deposit, 05 - Collected by third parties, 99 Others.  |
|Document  |payment_method2  |String  |2  |String value (alphanumeric or numeric) that corresponds to the means of payment used. Several types of payment methods are allowed simultaneously, but the proportion of each of them is not indicated: 01 Cash, 02 Card, 03 Check, 04 Transfer - bank deposit, 05 - Collected by third parties, 99 Others.  |
|Document  |payment_method3  |String  |2  |String value (alphanumeric or numeric) that corresponds to the means of payment used. Several types of payment methods are allowed simultaneously, but the proportion of each of them is not indicated: 01 Cash, 02 Card, 03 Check, 04 Transfer - bank deposit, 05 - Collected by third parties, 99 Others.  |
|Document  |payment_method4  |String  |2  |String value (alphanumeric or numeric) that corresponds to the means of payment used. Several types of payment methods are allowed simultaneously, but the proportion of each of them is not indicated: 01 Cash, 02 Card, 03 Check, 04 Transfer - bank deposit, 05 - Collected by third parties, 99 Others.  |
|Document  |payment_method5  |String  |2  |String value (alphanumeric or numeric) that corresponds to the means of payment used. Several types of payment methods are allowed simultaneously, but the proportion of each of them is not indicated: 01 Cash, 02 Card, 03 Check, 04 Transfer - bank deposit, 05 - Collected by third parties, 99 Others.  |
|Document  |payment_method99  |String  |2  |String value (alphanumeric or numeric) that corresponds to the means of payment used. Several types of payment methods are allowed simultaneously, but the proportion of each of them is not indicated: 01 Cash, 02 Card, 03 Check, 04 Transfer - bank deposit, 05 - Collected by third parties, 99 Others.  |
|Transaction  |total_taxable_services  |Float  |2 to 18  |Numeric data with 1 to 5 decimal places, corresponds to the total amount of services taxed with VAT. |
|Transaction  |total_non_taxable_services  |Float  |2 to 18  |Numeric data with 1 to 5 decimal places, corresponds to the total amount of services non-taxed with VAT.  |
|Transaction  |total_taxable_goods  |Float  |2 to 18  |Numeric data with 1 to 5 decimal places, corresponds to the total amount of goods taxed with VAT. |
|Transaction  |total_non_taxable_goods  |Float  |2 to 18  |Numeric data with 1 to 5 decimal places, corresponds to the total amount of goods non-taxed with VAT. |
|Transaction  |total_taxable  |Float  |2 to 18  |Numeric data with 1 to 5 decimal places, corresponds to the total amount of taxable value.  |
|Transaction  |total_non_taxable  |Float  |2 to 18  |Numeric data with 1 to 5 decimal places, corresponds to the total amount of non-taxable value. |
|Transaction  |total_sales  |Float  |2 to 18  |Numeric data with 1 to 5 decimal places. It is obtained by adding the total_taxable and non-taxable values of goods and services.  |
|Transaction  |total_discounts  |Float  |2 to 18  |Numeric data with 1 to 5 decimal places. It is obtained from the sum of all the discount amount granted fields. |
|Transaction  |total_voucher  |Float  |2 to 18  |Numeric data with 1 to 5 decimal places. It is obtained from the sum of the fields "Total sales" minus "Total discount" (this result is recorded in the field "total net sales", plus "total amount of tax" and "total other charges" minus "total VAT refunded". Some of these fields are not found in this extraction. |
|Transaction  |total_tax  |Float  |2 to 18  |Numeric data with 1 to 5 decimal places. It is obtained from the sum of all tax amount fields, e.g. VAT, excise and specific taxes. |

---

## Taxpayer profile file

|ENTITY  |FIELD NAME | TYPE  | LENGTH  | DESCRIPTION  
|--|--|--|--|--|
|taxpayer  |taxpayer_id  |String  |6 to 16  |Tax ID issued by the Tax Authority to the taxpayer. Unique ID.  Tax ID code (alphanumeric) issued by the tax agency to the taxpayer during the registration. It is a unique value corresponding to the issuer_id, or receiver_id in the e-Invoicing dataset.  |
|taxpayer  |taxpayer_type  |String |1 to 2  |String (alphanumeric) code to identify the type of taxpayer: Individuals, Businesses, Self-Employed, Charities and Non-profits, Individuals International, Businesses International, Government Liaisons, etc. For the issuer_code it can be customized by the tax agency, but should be on the length and data type specifications. |
|taxpayer  |fiscal_condition  |String  |2  |Two character code that identifies the fiscal condition of the taxpayer. Example: AA = Active, SS = Suspended, IN = Inactive, CC = Closed.  |
|taxpayer  |regime_name  |String  |2 to 40  |Name of the tax scheme registered by the company. Codes according to the country tax policy. Any string value in the expected length.  |
|taxpayer  |taxpayer_size  |String  |2  |Two character code that identifies the size of the taxpayer. XS = Extra Small, SS = Small, MS = Medium Small, MM = Medium, LL = Large, XL = Extra Large or Big Taxpayer  |
|taxpayer  |main_activity  |String  |4 to 6  |String value (numeric value) that indicates the code of the primary economic activity from the taxpayer registration. The activity code should follow (recommended) the International Standard Industrial Classification of All Economic Activities (ISIC) defined by the United Nations. The code comprises three segments: Division, Group, and Class, equivalent to 4 digits, and countries can add extra two digits for specific localization. |
|taxpayer  |sec1_activity  |String  |4 to 6  |String value (numeric value) that indicates the code of the secondary economic activity from the taxpayer registration. The activity code should follow (recommended) the International Standard Industrial Classification of All Economic Activities (ISIC) defined by the United Nations. The code comprises three segments: Division, Group, and Class, equivalent to 4 digits, and countries can add extra two digits for specific localization. |
|taxpayer  |sec2_activity  |String  |4 to 6  |String value (numeric value) that indicates the code of the third economic activity from the taxpayer registration. The activity code should follow (recommended) the International Standard Industrial Classification of All Economic Activities (ISIC) defined by the United Nations. The code comprises three segments: Division, Group, and Class, equivalent to 4 digits, and countries can add extra two digits for specific localization. |
|taxpayer  |employees_number  |Integer  |0 to 3999999  |Number of employees declared by the company on the registration, or updated during reporting.  |
|taxpayer  |legal_reg_date  |Date  |YYYY-MM-DD   |Date at which the company is registered at the Ministry of Economy, or Chambers of Commerce or equivalent government entity, in the format YYYY-MM-DD   |
|taxpayer  |tax_reg_date  |Date  |YYYY-MM-DD  |Date at which the company is registered at the Tax Authority to obtain a TaxID, in the format YYYY-MM-DD   |
|taxpayer  |e_inv_enroll_date  |Date  |YYYY-MM-DD   |Date at which the company is enrolled to issue electronic invoices, in the format YYYY-MM-DD   |
|taxpayer  |reported_assets  |Integer  |1  |Confirmation if the company reported any assets to any government agency. 1 = Yes, 0 = N  |
|taxpayer  |total_capital  |Float  |6 to 18  |Numeric data with 2 to 5 decimal places, corresponds to the total amount of capital informed by the taxpayer  |
|taxpayer  |social_capital  |Float  |6 to 18  |Numeric data with 2 to 5 decimal places, corresponds to the social amount of capital informed by the taxpayer  |
|taxpayer  |total_assets  |Float  |6 to 18  |Numeric data with 2 to 5 decimal places, corresponds to the total assets informed by the taxpayer  |
|taxpayer  |total_fixed_assets  |Float  |6 to 18  |Numeric data with 2 to 5 decimal places, corresponds to the total fixed assets of capital informed by the taxpayer  |
|taxpayer  |total_liabilities  |Float  |6 to 18  |Numeric data with 2 to 5 decimal places, corresponds to the total liabilities informed by the taxpayer  |
|taxpayer  |gross_income  |Float  |6 to 18  |Numeric data with 2 to 5 decimal places, corresponds to the gross income reported by the taxpayer in its tax compliance reporting  |
|taxpayer  |net_income  |Float  |6 to 18  |Numeric data with 2 to 5 decimal places, corresponds to the net income reported by the taxpayer in its tax compliance reporting  |
|taxpayer  |total_vat_sales  |Float  |6 to 18  |Numeric data with 2 to 5 decimal places, corresponds to the total VAT sales reported by the taxpayer in its tax compliance reporting  |
|taxpayer  |credited_einvoicing_value  |Float  |6 to 18  |Numeric data with 2 to 5 decimal places, corresponds to the credited e-Invoicing valued credited to the taxpayer  |
|taxpayer  |state  |String  |2 to 4  |Code to identify the state of registration for the taxpayer  |
|taxpayer  |municipality  |String  |2 to 4  |Code to identify the municipality of registration for the taxpayer  |
|taxpayer  |city  |String  |2 to 4  |Code to identify the city of registration for the taxpayer.  |

---

## Exchange Rate file

|ENTITY  |FIELD  |TYPE  |LENGHT  |DESCRIPTION  |
|--|--|--|--|--|
|Exchange Rate  |ISO_CODE  |String  |3  |ISO Code for the different currencies supported by the national e-Invoicing system. Code according to ISO 4217 <br/><br/> Reference: <https://en.wikipedia.org/wiki/ISO_4217>
|Exchange Rate  |DESCRIPTION  |String  |256  |Currency Name. Example: USA Dollar, Pound Sterling, Mexican Peso, etc.   |
|Exchange Rate  |Day  |Date  |YYYY-MM-DD  |Historical day in the format YYYY-MM-DD, from the minimum issued_date reported in the e-Invoicing dataset to the maximum date reported in the issued_date in the e-Invoicing dataset   |
