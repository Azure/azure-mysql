# Azure Data Factory with MySQL

## Setup

## Create Linked Services

- Switch to the Azure Portal, browse to the **mysqldevSUFFIX** Azure Data Factory instance
- Select **Open Azure Data Factory Studio**
- In the left navigation, select the **Manage** tab
- Select **Linked servics**, select the **+ New** button
- For the type, select **Azure Database for MySQL**
- For the name, type **ContosoStore**
- For the account selection, select **From Azure Subscription**
- Select the subscription
- Select the **mysqldevSUFFIX** Azure Database for MySQL server
- For the database name, type **ContosoStore**
- For the username, type **wsuser@mysqldevSUFFIX**
- For the password, type **Solliance123**
- Select **Test connection**, ensure that a success message is displayed.
- Select **Create**
- Select **Linked servics**, select the **+ New** button
- For the type, select **Azure Data Lake Storage Gen2**
- Select **Continue**
- For the name type **AzStorage**
- Select the subscription
- Select the **mysqldevSUFFIXdl** storage account
- Select **Create**

## Create Dataset (MySQL)

- Seelct the **Author** tab
- Select the **+** button, then select **Data Set**
- For the type, select **Azure Database for MySQL**
- Select **Continue**
- For the name, type **orders_database**
- For the linked service, select **ContosoStore**
- For the table name, select **orders**
- Select **Continue**
- For the table, select **users**
- Select **OK**

## Create Dataset (Storage)

- Select the **+** button, then select **Data Set**
- For the type, select **Azure Data Lake Storage Gen2**
- Select **Continue**
- For the data format, select **JSON**
- Select **Continue**
- For the name, type **orders_storage**
- For the linked service, select **AzStorage**
- For the file system, type **orders**
- Select **OK**

## Create a Pipeline

- Select the **+** button, then select **Pipeline->Pipeline**
- For the name, type **mysql_to_storage**
- Expand **Move & transform**
- Drag the **Copy data** activity to the design surface
- In the **General** tab, for the pipeline name, type **mysql_to_storage**
- Select **Source**, then select the **orders_database** data set
- For the **Use query**, select **Query**
- Select **Add dynamic content**
- For the query text, type **select * from orders where created_at >= '@pipeline().parameters.LastCreateDate'**
- Select **Sink**, then select the **orders_storage** data set
- Select the main pipeline canvas, then select **Parameters**
- Select **+ New**
- For the name, tyep **LastCreateDate**
- For the type, select **String**
- For the default value, type **@trigger().scheduledTime**

## Add a trigger

- Select the **Add trigger** button
- Select **New/Edit**
- Select **New**
- For the name, type **UserScheduleTrigger**
- For the recurrance, select **1 day**
- Select **Ok**
- For the pipeline parameter value, type **@trigger().scheduledTime**
- Select **OK**

## Publish

- Select **Publish all**
- Select **Publish**

## Test the pipeline

- Select the **Trigger (1)** button
- Select **Trigger now**
- Select **OK**
- Open a new browser window to the Azure Portal
- Browse to the storage account
- Under **Data storage**, select **Containers**
- Select the **orders** container
- Notice that a new file is created that contains the exported data.
