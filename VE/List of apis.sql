API, Report, and Master Data Update
API Status

Purchase Order APIs are working correctly, no changes are required.

The following APIs are also stable and working as expected:

SODetailRequest

GetMOComponentsRequest

All other Sales, Packing & Assembly Order APIs also will need to check.

Report Enhancement Requirement

Currently, reports are client-based, not organization-based.

Initially, the system was implemented with only one organization, so client-based reports were sufficient.

As we plan to roll out the system across multiple depots and departments, we need to:

Create a separate organization for each department/depot.

Modify existing reports to be organization-based to ensure correct data visibility per organization.

Master Data Organization Update (New Requirement)

We need to modify existing records in the following windows:

Product

Locator Type

Department

Currently, these records are assigned to the organization “VinayElectrical”.

To support usage across all organizations, we need to:

Change the Organization value from “VinayElectrical” to “*” in the above three windows.


--------------------------------------------------------------------------------------------------
Alert Dashboard Window:

First, we need to add a checkbox key in the Temperature table.

When the Acknowledgement option is clicked, the database process should run internally and mark the selected records as acknowledged. After refreshing, those acknowledged records should no longer appear in the list.

Finally, if there are 100 records in total, the Dashboard widget should display only 5 records at a time. After clicking page number 2, it should show records 6–10, and so on.