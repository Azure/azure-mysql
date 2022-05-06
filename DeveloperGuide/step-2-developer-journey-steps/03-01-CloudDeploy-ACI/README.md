# Migrate to Azure Container Instances (ACI)

Now that containerized versions of the application exists, they can now be hosted in several resource types in Azure. Here, we explore Azure Container Instances (ACI).

## Push images to Azure Container Registry

1. If they haven't been already, push the images to the Azure Container Registry using the [Push Images to Acr](./../Misc/01_PushImagesToAcr.md) article.

## Run images in ACI

1. Run the following commands to create two new container instances:

    ```PowerShell
    $acrName = "mysqldevSUFFIX";
    $resourceName = $acrName;
    $resourceGroupName = "{RESOURCE_GROUP_NAME}";

    $rg = Get-AzResourceGroup $resourceGroupName;

    $acr = Get-AzContainerRegistry -Name $acrName -ResourceGroupName $resourceGroupName;
    $creds = $acr | Get-AzContainerRegistryCredential

    $imageRegistryCredential = New-AzContainerGroupImageRegistryCredentialObject -Server "$acrName.azurecr.io" -Username $creds.username -Password (ConvertTo-SecureString $creds.password -AsPlainText -Force)

    $storageKey = $(Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -Name $resourceName).Value[0];
    $context = $(New-AzStorageContext -StorageAccountName $resourceName -StorageAccountKey $storageKey);

    #create a new azure file share
    New-AzStorageShare -Name "db-volume" -Context $context
    
    $containerName = "store-db";
    $env1 = New-AzContainerInstanceEnvironmentVariableObject -Name "MYSQL_DATABASE" -Value "contosostore";
    $env2 = New-AzContainerInstanceEnvironmentVariableObject -Name "MYSQL_ROOT_PASSWORD" -Value "root";
    $env3 = New-AzContainerInstanceEnvironmentVariableObject -Name "MYSQL_ROOT_HOST" -Value "%";
    $port1 = New-AzContainerInstancePortObject -Port 3306 -Protocol TCP;
    $volume = New-AzContainerGroupVolumeObject -Name "db-volume" -AzureFileShareName "db-volume" -AzureFileStorageAccountName $resourceName -AzureFileStorageAccountKey (ConvertTo-SecureString $storageKey -AsPlainText -Force);
    $vMount = @{};
    $vMount.MountPath = "/var/lib/mysql";
    $vMount.Name = "db-volume";
    $container = New-AzContainerInstanceObject -Name $containerName -Image "$acrName.azurecr.io/store-db" -Port @($port1) -EnvironmentVariable @($env1, $env2, $env3) -VolumeMount @($vMount);
    New-AzContainerGroup -ResourceGroupName $resourceGroupName -Name $containerName -Container $container -OsType Linux -Location $rg.location -ImageRegistryCredential $imageRegistryCredential -IpAddressType Public -Volume $volume;
    ```

2. Browse to the Azure Portal
3. Search for the **store-db** Container instance and select it
4. Copy the public IP address
5. Setup the web container, replace the `IP_ADDRESS` with the one copied above:

    ```Powershell
    $containerName = "store-web";
    $env1 = New-AzContainerInstanceEnvironmentVariableObject -Name "DB_DATABASE" -Value "contosostore";
    $env2 = New-AzContainerInstanceEnvironmentVariableObject -Name "DB_USERNAME" -Value "root";
    $env3 = New-AzContainerInstanceEnvironmentVariableObject -Name "DB_PASSWORD" -Value "root";
    $env4 = New-AzContainerInstanceEnvironmentVariableObject -Name "DB_HOST" -Value "IP_ADDRESS";
    $port1 = New-AzContainerInstancePortObject -Port 80 -Protocol TCP;
    $port2 = New-AzContainerInstancePortObject -Port 8080 -Protocol TCP;
    $container = New-AzContainerInstanceObject -Name mysql-dev-web -Image "$acrName.azurecr.io/store-web" -EnvironmentVariable @($env1, $env2, $env3, $env4) -Port @($port1, $port2);
    New-AzContainerGroup -ResourceGroupName $resourceGroupName -Name $containerName -Container $container -OsType Linux -Location $rg.location -ImageRegistryCredential $imageRegistryCredential -IpAddressType Public;
    ```

## Test the images

1. Browse to the Azure Portal
2. Search for the **store-web** Container instance and select it
3. Copy the public IP address and then open a browser window to `http://IP_ADDRESS/default.php`

## Multi-container single app service deployment

In the previous steps, a container instance was created for each of the containers, however, it is possible to create a multi-container container instance where all services are encapsulated into one container instance instance using Azure CLI.

1. Create the following `docker-compose-contoso.yml` file, be sure to replace the `SUFFIX`:

    ```yaml
    version: '3.8'
    services:
    web:
        image: mysqldevSUFFIX.azurecr.io/store-web:latest
        environment:
        - DB_DATABASE=contosostore
        - DB_USERNAME=root
        - DB_PASSWORD=root
        - DB_HOST=db
        - DB_PORT=3306
        ports:
        - "8080:80" 
        depends_on:
        - db 
    db:
        image: mysqldevSUFFIX.azurecr.io/store-db:latest
        volumes:
        - ${WEBAPP_STORAGE_HOME}/site/database:/var/lib/mysql
        restart: always
        environment:
        - MYSQL_ROOT_PASSWORD=root
        - MYSQL_DATABASE=contosostore
        ports:
        - "3306:3306"
    phpmyadmin:
        image: phpmyadmin/phpmyadmin
        ports:
            - '8081:80'
        restart: always
        environment:
            PMA_HOST: db
        depends_on:
          - db
    ```

2. In a PowerShell window, run the following command, be sure to replace the `SUFFIX` and other variable values:

    ```powershell
    $acrName = "mysqldevSUFFIX";
    $resourceName = $acrName;
    $resourceGroupName = "{RESOURCE_GROUP_NAME}";

    $acr = Get-AzContainerRegistry -Name $acrName -ResourceGroupName $resourceGroupName;
    $creds = $acr | Get-AzContainerRegistryCredential;

    az login;

    az webapp create --resource-group $resourceGroupName --plan "$resourceName-sf" --name $resourceName --multicontainer-config-type compose --multicontainer-config-file docker-compose-contoso.yml;

    az webapp config appsettings set --resource-group $resourceGroupName --name $resourceName --settings DOCKER_REGISTRY_SERVER_USERNAME=$($creds.Username)

    az webapp config appsettings set --resource-group $resourceGroupName --name $resourceName --settings DOCKER_REGISTRY_SERVER_URL="$resourceName.azurecr.io"

    az webapp config appsettings set --resource-group $resourceGroupName --name $resourceName --settings DOCKER_REGISTRY_SERVER_PASSWORD=$($creds.Password)

    az webapp config appsettings set --resource-group $resourceGroupName --name $resourceName --settings DB_HOST="DB"

    az webapp config appsettings set --resource-group $resourceGroupName --name $resourceName --settings DB_USERNAME="root"

    az webapp config appsettings set --resource-group $resourceGroupName --name $resourceName --settings DB_PASSWORD="root"

    az webapp config appsettings set --resource-group $resourceGroupName --name $resourceName --settings DB_DATABASE="ContosoStore"

    az webapp config appsettings set --resource-group $resourceGroupName --name $resourceName --settings DB_PORT="3306"

    az webapp config appsettings set --resource-group $resourceGroupName --name $resourceName --settings WEBSITES_ENABLE_APP_SERVICE_STORAGE=TRUE

    az webapp config container set --resource-group $resourceGroupName --name $resourceName --multicontainer-config-type compose --multicontainer-config-file docker-compose-contoso.yml
    ```

3. Switch back to the Azure Portal, browse to the Azure App Service. If troubleshooting is needed, view the container logs by browsing to `https://mysqldevSUFFIX.scm.azurewebsites.net/api/logs/docker`.  Copy the path to the docker file and paste it into a new window, review the logs and fix any errors.
