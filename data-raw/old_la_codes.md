## Background

This is a step by step guide to adding the three-digit ("old") local authority codes to the geo_hierarchy lookup, including the code you'll need to use. Even though these codes are referred to as "old", they are actively used and updated by the department in line with any local authority boundary changes.

## Step by step guide

1.  Download the 'English', 'Welsh' and 'Other' three digit local authority code tables from the [Get Information about Schools](https://get-information-schools.service.gov.uk/) (GIAs) website by going to the [Local authority name and associated codes page](https://get-information-schools.service.gov.uk/Guidance/LaNameCodes), scrolling to the bottom and clicking on the 'Download' button.

    -   Save those tables in the 'data' folder of the dfeR repo. This step is temporary.

2.  Go to the [Explore Education Statistics screener repository](https://github.com/dfe-analytical-services/dfe-published-data-qa/blob/main/data/las.csv) and download the 'las.csv' file.

    -   Save this file in the 'data' folder of the dfeR repo. This step is temporary.

3.  Run the code in data-raw/old_la_codes.R to join the data and save a new version of the lookup.

4.  Run `devtools::check()` to check everything is working as expected.

5.  Remove the screener (la.csv) and GIAS CSV files saved in the data folder.

6.  Run the code in data-raw/geo_hierarchy.R to update the geo_hierarchy dataset.

7.  Update the documentation and tests if applicable by following [dfeR contributing guidance](https://dfe-analytical-services.github.io/dfeR/CONTRIBUTING.html) and using the workflow outlined to carry out necessary checks.
