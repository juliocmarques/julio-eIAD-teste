# Azure Monitor Workbook for e-IAD
Azure Monitor is used to collect monitoring telemetary and operational logs. Azure Workbooks let you compile a set of queries and resource metrics over a shared time span to see how the system was behaving at a given time range. This allows us to have a custom set of queries that are focussed on the e-IAD accelerator.

Currently we have one workbook, it's JSON definition is checked in here `/workspaces/eIAD/infrastructure/modules/monitor/Azure_Synapse_Spark_Application.workbook`.

At the top of the workbook is a set of parameters. The most important is the Time Range as this drives all the queries in the workbook.

If you forget to use these parameters the queries will either deploy with a static resource or a fixed time range, which wouldn't make them useful!

- `TimeRange` sets the range over which all graphs and queries in the workbook operate

## Updating the workbook

The developer flow for updating an existing workbook is:

- Update the workbook within Azure Monitor
  - Make any changes directly in the workbook
- Export the result 
  - Select the </> Advanced Editor
  - Change Template Type to `Gallery Template`
  - Click the ⬇ icon to download as a local 'workbook' file
- Commit to git
   - Overwrite the existing .workbook file

## Writing a query

Here is an example of the minimum steps to add a query.

1. Take the query you have already written and remove the time filter
2. In the "Time Range" drop down selected the "TimeRange" Parameter for the workbook this ensures your query updates to the selected timerange

## Saving your edits for deployment

1. Edit the workbook and open the "Advanced editor"
   - Open the workbook and click "edit"
   - On the top bar look for a button with `</>` for advanced editor - click this one.
1. Select the "Gallery View"
1. Navigate to the workbook in the solution `/workspaces/eIAD/infrastructure/modules/monitor/Azure_Synapse_Spark_Application.workbook`
1. Copy the content of the "Gallery View" into the JSON file on disk
1. Remove the defaults section at the bottom of the file
1. Search for any references to `/subscriptions/...`. If you find any of these outside of the parameters definitions it means you've got a hard coded reference to a resource. Revisit the sets for adding metrics or queries to and ensure you use the parameters NOT directly selected resources.