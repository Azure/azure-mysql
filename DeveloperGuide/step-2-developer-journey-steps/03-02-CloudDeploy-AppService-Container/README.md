# Migrate to Azure App Service Containers

Now that a containerized version of the applications exists, it can now be hosted in several places in Azure. Here we explore Azure App Service Containers.

## Push images to Azure Container Registry

1. If they have not been pushed already, push the images to the Azure Container Registry using the [Push Images to Acr](./../Misc/01_PushImagesToAcr.md) article.

## Run images in Azure App Service

1. Run the following to create the app service containers, be sure to replace the `SUFFIX` and `RESOURCE_GROUP_NAME`:

    ```powershell
    $suffix = "SUFFIX"
    $acrName = "mysqldev$suffix";
    $appPlan = "mysqldev$suffix-linux";
    $image = "$acrName.azure.io/store-web";
    $resourceGroupName = "{RESOURCE_GROUP_NAME}";

    $acr = Get-AzContainerRegistry -Name $acrName -ResourceGroupName $resourceGroupName;
    $creds = $acr | Get-AzContainerRegistryCredential;

    $name = "mysqldev$suffix-app-web";
    New-AzWebApp -Name $name -ResourceGroupName $resourceGroupName -AppServicePlan $appPlan -ContainerImageName $image -ContainerRegistryUrl $acr.loginserver -ContainerRegistryUser $creds.username -ContainerRegistryPassword (ConvertTo-SecureString $creds.password -AsPlainText -Force) -Location $acr.location;

    $config = Get-AzResource -ResourceGroupName $resourceGroupName -ResourceType Microsoft.Web/sites/config -ResourceName $name -ApiVersion 2018-02-01
    $config.Properties.linuxFxVersion = "DOCKER|$($image):latest"
    $config | Set-AzResource -ApiVersion 2018-02-01 -Debug -Force

    $name = "mysqldev$suffix-app-db";
    $image = "$acrName.azure.io/store-db";
    New-AzWebApp -Name $name -ResourceGroupName $resourceGroupName -AppServicePlan $appPlan -ContainerImageName $image -ContainerRegistryUrl $acr.loginserver -ContainerRegistryUser $creds.username -ContainerRegistryPassword (ConvertTo-SecureString $creds.password -AsPlainText -Force) -Location $acr.location;

    $config = Get-AzResource -ResourceGroupName $resourceGroupName -ResourceType Microsoft.Web/sites/config -ResourceName $name -ApiVersion 2018-02-01
    $config.Properties.linuxFxVersion = "DOCKER|$($image):latest"
    $config | Set-AzResource -ApiVersion 2018-02-01 -Debug -Force

    az webapp create --resource-group $resourceGroupName --plan $appPlan --name $name --deployment-container-image-name $image
    az webapp config set --resource-group $resourceGroupName --name $name --linux-fx-version "DOCKER|$image:latest"
    az webapp config appsettings set --resource-group $resourceGroupName --name $name --settings WEBSITES_PORT=3306
    ```

## Test the containers

1. Browse to the Azure Portal
2. Select the **mysqldevSUFFIX-app-db** app service
3. On the **Overview** tabe, record the **URL**
4. Under **Monitoring**, select **App Service Logs**
5. Select **File System**
6. For **Days**, type **7**
7. Select **Save**
8. Under **Settings**, select **Configuration**
9. Select **New application setting**, add the following, replace the `DB_URL` with the one recorded previously from the database container, replace the `APP_URL` with the one  recorded for the application web:
     - `MYSQL_ROOT_PASSWORD` = `Solliance123`
     - `WEBSITES_PORT` = `3306`
10. Select **Save**, then select **Continue**
11. Select the **mysqldevSUFFIX-app-web** app service
12. On the **Overview** tabe, record the **URL**
13. Under **Monitoring**, select **App Service Logs**
14. Select **File System**
15. For **Days**, type **7**
16. Select **Save**
17. Under **Settings**, select **Configuration**
18. Select **New application setting**, add the following, replace the `DB_URL` with the one recorded previously from the database container, replace the `APP_URL` with the one recorded for the application web:
     - `DB_HOST` = {DB_URL}
     - `DB_USERNAME` = `root`
     - `DB_PASSWORD` = `Solliance123`
     - `DB_DATABASE` = `contosostore`
     - `DB_PORT` = `3306`
     - `APP_URL` = {APP_URL}

    > **NOTE** It is possible to edit multiple by selecting  **Advanced edit** and then copying the below values in, be sure to replace the `SUFFIX`

    ```text
    {
        "name": "DB_HOST",
        "value": "mysqldevSUFFIX-app-db.azurewebsites.net",
        "slotSetting": false
    },
    {
        "name": "DB_USERNAME",
        "value": "wsuser",
        "slotSetting": false
    },
    {
        "name": "DB_PASSWORD",
        "value": "Solliance",
        "slotSetting": false
    },
    {
        "name": "DB_DATABASE",
        "value": "contosostore",
        "slotSetting": false
    },
    {
        "name": "DB_PORT",
        "value": "3306",
        "slotSetting": false
    },
    {
        "name": "APP_URL",
        "value": "https://mysqldevSUFFIX-app-web.azurewebsites.net/",
        "slotSetting": false
    }
    ```

19.  Select **Save**
20.  Browse to the **mysqldevSUFFIX-app-web** app service url, the web site will load but it has database errors.

## Troubleshooting

1. If no results are displayed, review the logs for each container instance
   1. Browse to the app service
   2. Under **Monitoring**, select **Log stream**
   3. Review the startup logs, notice that the database instance did not respond to an HTTP request on port 3306.  This is because an app service container will only work with HTTP based container images unless it is a multicontainer deployment.
2. Change the application settings for the web container to point to the Azure Database for MySQL Single Server instance
3. Refresh the web site, it should now load successfully.
