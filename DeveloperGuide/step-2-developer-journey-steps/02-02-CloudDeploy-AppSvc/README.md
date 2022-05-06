# Cloud Deployment to Azure App Service

This is a simple app that runs PHP code to connect to a MYSQL database.  The application and database must be migrated to Azure App Service and Azure Database for MySQL.

## Basic Deployment

### Update env

1. Open the `C:\labfiles\microsoft-mysql-developer-guide` folder in Visual Studio code
2. If prompted, select **Yes, I trust the authors**
3. Switch to the browser, browse to the **mysqldevSUFFIX** app service
4. Select the **Overview** link, copy the **URL** for use later

### Deploy the Application

1. Open a terminal window, run the following to deploy the zip to Azure, be sure to replace the `SUFFIX`:

    ```PowerShell
    cd "C:\labfiles\microsoft-mysql-developer-guide"

    Connect-AzAccount

    #if more than on subscription
    Select-AzSubscription "SUBSCRIPTION_NAME";

    $suffix = "SUFFIX";
    $resourceGroupName = "RESOURCE_GROUP_NAME";

    $appName = "mysqldev$suffix-linux";
    $app = Get-AzWebApp -ResourceGroupName $resourceGroupName -Name $appName

    #NOTE: This can't be used this for linux based deployments
    #Compress-Archive -Path .\sample-php-app\* -DestinationPath site.zip -force

    7z a -r ./site.zip ./sample-php-app/*
    
    #Publish-AzWebApp -WebApp $app -ArchivePath "C:\labfiles\microsoft-mysql-developer-guide\site.zip" -force

    #Reference - https://docs.microsoft.com/en-us/azure/app-service/deploy-local-git?tabs=cli

    az login --scope https://management.core.windows.net//.default

    az account set --name "SUBSCRIPTION_NAME"

    #setup local git
    az webapp deployment source config-local-git --name $appName --resource-group $resourceGroupName;

    #set the username and password
    az webapp deployment user set --user-name "mysqldev$suffix" --password "Solliance123"

    #get the github link to the azure app service
    #$url = az webapp deployment list-publishing-profiles --resource-group $resourceGroupName --name $appName

    $url = az webapp deployment list-publishing-credentials --resource-group $resourceGroupName --name $appName --query scmUri
    $url = $url.replace("`"","") + "/$appName.git"

    az webapp config appsettings set --name $appName --resource-group $resourceGroupName --settings DEPLOYMENT_BRANCH='main'

    #setup git
    git config --global user.email "you@example.com"
    git config --global user.name "Your Name"
    git config --global http.postBuffer 524288000

    #do the deployment
    cd "C:\labfiles\microsoft-mysql-developer-guide"

    #remove current git setup
    remove-item .git -force -Recurse

    cd "C:\labfiles\microsoft-mysql-developer-guide\sample-php-app"

    git init
    git remote rm origin
    git remote rm azure
    git remote add azure $url
    git add .
    git commit -m "init commit"
    git push azure main

    #only works with 7.4 PHP / Apache
    #az webapp deploy --resource-group $resourceGroupName --name $appName --src-path "C:\labfiles\microsoft-mysql-developer-guide\site.zip" --type zip

    ```

### Update Application Settings

1. Open the Azure Portal
2. Browse to the **mysqldevSUFFIX** app service
3. Under **Development tools**, select **SSH**, then select **Go**
4. Login using your lab credentials
5. Run the following:

    ```bash
    cp /etc/nginx/sites-available/default /home/site/default
    ```

6. Edit the `default` file

    ```bash
    nano /home/site/default
    ```

7. Modify the root to be the following:

    ```bash
    root /home/site/wwwroot/public
    ```

8. Add the following to the `location` section after the `index  index.php index.html index.htm hostingstart.html;` line:

    ```bash
    try_files $uri $uri/ /index.php?$args;
    ```

    ![This image demonstrates the changes made to the /home/site/default file in the SSH session.](./media/web-server-config.png "Web server configuration file changes")

9. Press **Ctrl-X**, then select **Y** to save the file
10. Add a startup.sh file:

   ```bash
    nano /home/site/startup.sh
    ```

10. Copy and paste the following:

    ```bash
    #!/bin/bash

    cp /home/site/default /etc/nginx/sites-available/default
    service nginx reload
    ```

12. Open the `.env` file in the text editor.

    ```bash
    nano /home/site/wwwroot/.env
    ```

13. Update the `APP_URL` parameter to the App Service URL (found on the **Overview** tab of the Azure portal). Then, set `ASSET_URL` to `APP_URL`.

    ```bash
    APP_URL=https://[APP SERVICE NAME].azurewebsites.net
    ASSET_URL = "${APP_URL}"
    ```

14. Run the following commands to setup the Larvael application:

    ```powershell
    composer.phar update

    php artisan config:clear

    php artisan key:generate
    ```

15. Switch back the Azure Portal and the app service, under **Settings**, select **Configuration**
16. Select **General settings**
17. In the startup command textbox, type `/home/site/startup.sh`
18. Select **Save**

### Test the Application

1. Browse to `https://mysqldevSUFFIX.azurewebsites.net/` to see the app load with SSL

### Add Firewall IP Rule and Azure Access

1. Switch to the Azure Portal
2. Browse to the `mysqldevSUFFIX` Azure Database for MySQL Single server
3. Under **Settings**, select **Connection security**
4. Select **Add current client IP address (...)**
<!--
5. Select the **Allow public access from any Azure Service within Azure to this server** checkbox
-->
5. Select the **Allow access to Azure services** toggle to **Yes**
6. Select **Save**

### Migrate the Database

1. Use the steps in [Migrate your database](./Misc/02_MigrateDatabase) article.

## Update the connection string

1. Switch to the Azure Portal
2. Browse to the **mysqldevSUFFIX** web application
3. Under **Development Tools**, select **SSH**
4. Select **Go->**
5. Select **Debug console->CMD**
6. Edit the **/home/site/wwwroot/pubic/database.php**:

    ```bash
    nano /home/site/wwwroot/pubic/database.php
    ```

7. Set the servername variable to `mysqldevSUFFIX.mysql.database.azure.com`
8. Set the username to `wsuser`
9. Set the password to `Solliance123`
10. Press **Ctrl-X**, then **Y** to save the file

## Test new settings #1

1. Browse to `https://mysqldevSUFFIX.azurewebsites.net/database.php`, an error about SSL settings should display.

## Fix SSL error

1. Download the `https://dl.cacerts.digicert.com/DigiCertGlobalRootCA.crt.pem` certificate
2. Switch back to the SSH window, run the following:

    ```bash
    cd /home/site/wwwroot/public

    wget https://dl.cacerts.digicert.com/DigiCertGlobalRootCA.crt.pem
    ```

3. Edit the `database.php` file

    ```php
    nano /home/site/wwwroot/public/database.php
    ```

4. Update the database connection to use ssl by uncommenting the `mysqli_ssl_set` method before the `mysqli_real_connect` method:

    ```php
    mysqli_ssl_set($conn,NULL,NULL, "DigiCertGlobalRootCA.crt.pem", NULL, NULL);
    ```

5. Press Ctrl-X, then Y to save the file

## Test new settings #2

1. Browse to `https://mysqldevSUFFIX.azurewebsites.net/database.php`, results should display.

## Update to use Environment Variables

Putting credential in the PHP files is not a best practice, it is better to utilize environment variables for this.

1. Switch back to the SSH window
2. Edit the **/home/site/wwwroot/pubic/database.php**:

    ```bash
    nano /home/site/wwwroot/pubic/database.php
    ```

3. Update the connection variables to the following:

    ```php
    $servername = getenv("APPSETTING_DB_HOST");
    $username = getenv("APPSETTING_DB_USERNAME");
    $password = getenv("APPSETTING_DB_PASSWORD");
    $dbname = getenv("APPSETTING_DB_DATABASE");
    ```

    > **NOTE** Azure App Service adds the `APPSETTING` prefix to all environment variables

4. Edit the **/home/site/wwwroot/config/database.php**:

    ```bash
    nano /home/site/wwwroot/config/database.php
    ```

5. Update the mysql connection to utilize the environment variables:

    ```php
    'host' => getenv('APPSETTING_DB_HOST'),
    'port' => getenv('APPSETTING_DB_PORT'),
    'database' => getenv('APPSETTING_DB_DATABASE'),
    'username' => getenv('APPSETTING_DB_USERNAME'),
    'password' => getenv('APPSETTING_DB_PASSWORD'),
    ```

6. Add the environment variables to the App Service:
   - Browse to the Azure Portal
   - Select the **mysqldevSUFFIX** app service
   - Under **Settings**, select **Configuration**
   - Select **New application setting**
   - Add the following:
     - `DB_HOST` = `mysqldevSUFFIX.mysql.database.azure.com`
     - `DB_USERNAME` = `wsuser@mysqldevSUFFIX`
     - `DB_PASSWORD` = `Solliance123`
     - `DB_DATABASE` = `contosostore`
     - `DB_PORT` = `3306`
     - `APP_URL` = `https://mysqldevSUFFIX.azurewebsites.net`
    - Select **Save**, then select **Continue**

## Test new settings #3

1. Browse to `https://mysqldevSUFFIX.azurewebsites.net/database.php`, results should display.

## Create Azure Key Vault values

1. Switch to the Azure Portal
2. Browse to the **mysqldevSUFFIX-kv** Key Vault
3. Under **Settings** select **Access Policies**
4. Select **Add Access Policy**
5. For the secret permission, select the dropdown, then select **All**
6. For the principal, select the lab guide user account
7. Select **Add**
8. Select **Save**
9. Under **Settings**, select **Secrets**
10. Select **Generate/Import**
11. For the name, type **MySQLPassword**
12. For the value, type **Solliance123**
13. Select **Create**

## Create Managed Service Identity

1. Switch to the Azure Portal
2. Browse to the **mysqldevSUFFIX** app service
3. Under **Settings**, select **Identity**
4. For the system assigned identity, toggle to **On**
5. Select **Save**, in the dialog, select **Yes**
6. Copy the **Object ID** for later user
7. Browse to the **mysqldevSUFFIX-kv** Key Vault
8. Under **Settings** select **Access Policies**
9. Select **Add Access Policy**
10. For the secret permission, select the dropdown, then select **All**
11. For the principal, select the new managed identity for the app service (use the copied object ID)
12. Select **Add**
13. Select **Save**
14. Under **Settings**, select **Secrets**
15. Select the **MySQLPassword**
16. Select the current version
17. Copy the secret identifier for later use

## Configure Environment Variables

1. Browse to the Azure Portal
2. Select the **mysqldevSUFFIX** app service
3. Under **Settings**, select **Configuration**
4. Select **New application setting**
5. For the name, type **MYSQL_PASSWORD**
6. Update it to the following, replace the `SUFFIX` value:

      ```text
      @Microsoft.KeyVault(SecretUri=https://mysqldevSUFFIX-kv.vault.azure.net/secrets/MySQLPassword/)
      ```

7. Select **OK**
8. Select **Save**, then select **Continue**. Ensure a green check mark appears
9. Select **Save**, ensure a green check mark appears.

## Update the files

1. Switch back to the SSH window
2. Edit the **/home/site/wwwroot/pubic/database.php**:

    ```bash
    nano /home/site/wwwroot/pubic/database.php
    ```

3. Update the connection variables to the following:

    ```php
    $password = getenv("APPSETTING_MYSQL_PASSWORD");
    ```

    > **NOTE** Azure App Service adds the `APPSETTING` prefix to all environment variables

4. Edit the **/home/site/wwwroot/config/database.php**:

    ```bash
    nano /home/site/wwwroot/config/database.php
    ```

5. Update the mysql connection to utilize the environment variables:

    ```php
    'password' => getenv('APPSETTING_MYSQL_PASSWORD')
    ```

## Test new settings #4

1. Browse to `https://mysqldevSUFFIX.azurewebsites.net/database.php`, results should display.
