# Azure Synapse Analytics with MySQL

## Create MySQL Linked Service

- Create a new Azure Synapse Analytics workspace
- Navigate to the **mysqldevSUFFIX** Azure Synapce Analytics Workspace
- Select the **Open Synapse Studio** link
- Select the **Manage** tab
- Under **External connections** select **Linked services**
- Select **+ New**
- For the type, select **Azure Database for MySQL**, select **Continue**
- For the name, type **ContosoStore**
- For the account selection, select **From Azure Subscription**
- Select the subscription
- Select the **mysqldevSUFFIX** Azure Database for MySQL server
- For the database name, type **ContosoStore**
- For the username, type **wsuser@mysqldevSUFFIX**
- For the password, type **Solliance123**
- Select **Test connection**, ensure a success message is displayed.
- Select **Create**

## Create PowerBI Workspace

- Open the Power BI Portal, https://powerbi.microsoft.com
- Sign in with your lab credentials
- In the left navigation, expand **Workspaces**
- Select **Create a workspace**
- For the name, type **MySQL**
- Select **Save**

## Create PowerBI Linked Service

- Select the **Manage** tab
- Under **External connections** select **Linked services**
- Select **+ New**
- For the type, select **Power BI**, select **Continue**
- For the name, type **PowerBI**
- Select the lab tenant
- Select the **MySQL** workspace
- Select **Create**

## Create Integration Dataset

- Select the **Data** tab
- Select the **+** button
- Select **Integration Dataset**
- For the type, select **Azure Database for MySQL**, select **Continue**
- For the name, type **ContosoStore_Orders**
- For the linked service **Contoso**
- Select **OK**
- Select **Publish all**, then select **Publish**

## Create PowerBI Desktop Report (Dataset)

- Open **Power BI Desktop**
- Select **Get data**
- Select **MySQL database**
- Select **Connect**
- For the servername, enter **mysqldevSUFFIX**
- For the database, select **contosostore**
- Select **OK**
- Select the **Database** tab
- For the user name, type **wsuser@mysqldevSUFFIX**
- For the password, type **Solliance123**
- Select **Connect**
- Check all the checkboxes
- Select **Load**
- Select **File->Save as**, save the report to the desktop as **MySQL**
- Select **Save**

## Publish the PowerBI report

- Select **File->Publish**
- Select **Publish to Power BI**
- Select the **MySQL** workspace
- Select **Select**

## Create PowerBI Report

- Select the **Develop** tab
- Select the **+** button
- Select **Power BI report**
- Select the **MySQL** data set
- Select **Create**
- In the **Fields** window, expand the **contosostore users** table
- Drag the name into the report window.
- Select **File->Save as**
- Save the report as **Contoso Users**
- Select **Save**, the report should load in the synapse workspace.
