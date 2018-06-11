Function New-AzureDmsActivity(
    $serviceName, 
    $projectName,
    $taskName,
    $targetserver,
    $targetuser,    
    $sourceserver,
    $sourceuser,
    $database
){

    $subscriptionId = "20d62cea-b252-4a42-b9d6-16ad2636b3a5"

    $resourceGroup = "BuildDemoPG"
    
    $location = "westus2"


    $sourcepwdsecured = Read-Host 'Enter password for user' $sourceuser 'on source server' -AsSecureString

    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sourcepwdsecured)
    $sourcepassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)

    $targetpwdsecured = Read-Host 'Enter password for user' $targetuser 'on target server' -AsSecureString

    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($targetpwdsecured)
    $targetpassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)

    Create-Activity $subscriptionId $resourceGroup $location $serviceName $projectName $taskName $database $sourceserver $sourceuser $sourcepassword $targetserver $targetuser $targetpassword
}

Function Get-AzureDmsActivity($serviceName, $projectName, $taskName) {
    $subscriptionId = "20d62cea-b252-4a42-b9d6-16ad2636b3a5"

    $resourceGroup = "BuildDemoPG"
 
    $location = "WestCentralUS"

    Get-Activity $subscriptionId $resourceGroup $location $serviceName $projectName $taskName
}

Function Cancel-AzureDmsActivity($subscriptionId, $resourceGroup, $location, $serviceName, $projectName, $taskName){
    $subscriptionId = "20d62cea-b252-4a42-b9d6-16ad2636b3a5"

    $resourceGroup = "BuildDemoPG"
 
    $location = "WestCentralUS"
    Cancel-Activity $subscriptionId $resourceGroup $location $serviceName $projectName $taskName
}

Function Delete-AzureDmsActivity($subscriptionId, $resourceGroup, $location, $serviceName, $projectName, $taskName){
    $subscriptionId = "20d62cea-b252-4a42-b9d6-16ad2636b3a5"

    $resourceGroup = "BuildDemoPG"
 
    $location = "WestCentralUS"
    Delete-Activity $subscriptionId $resourceGroup $location $serviceName $projectName $taskName
}

Function Set-CachedCredentials(){
    # Load ADAL Assemblies
    $adal = "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
    $adalforms = "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll"
    [System.Reflection.Assembly]::LoadFrom($adal) | Out-Null
    [System.Reflection.Assembly]::LoadFrom($adalforms) | Out-Null

    # Set Azure AD Tenant name
    $adTenant = "microsoft.onmicrosoft.com"

    # Set well-known client ID for Azure PowerShell
    $clientId = "1950a258-227b-4e31-a9cf-717495945fc2" 
    # Set redirect URI for Azure PowerShell
    $redirectUri = "urn:ietf:wg:oauth:2.0:oob"
    # Set Resource URI to Azure Service Management API
    $resourceAppIdURI = "https://management.core.windows.net/"
    # Set Authority to Azure AD Tenant
    $authority = "https://login.windows.net/$adTenant"
    # Create Authentication Context tied to Azure AD Tenant
    $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority

    # Acquire token
    return $authContext.AcquireToken($resourceAppIdURI, $clientId, $redirectUri, "Auto")
}

Function Create-Project ($subscriptionId, $resourceGroup, $location, $serviceName, $projectName){
    $authResult = Set-CachedCredentials

    # Create Authorization Header
    $authHeader = $authResult.CreateAuthorizationHeader()

    # Set HTTP request headers to include Authorization header
    $requestHeader = @{
        "x-ms-version" = " 2017-04-15-privatepreview";
        "Content-Type" = "application/json; charset=utf-8"
        "Authorization" = $authHeader
        }

    #Create project
    $azureMgmtUri = 'https://management.azure.com/subscriptions/' + $subscriptionId + '/resourceGroups/' + $resourceGroup + '/providers/Microsoft.DataMigration/services/' + $serviceName + '/projects/' + $projectName + '?api-version=2017-04-15-privatepreview';
    $body = '{"location":"' + $location + '","properties":{"sourcePlatform":"PostgreSQL","targetPlatform":"AzureDbForPostgreSQL","dataMovement": "Continuous"}}';
    $ProjectStatusResponse = Invoke-RestMethod -Uri $azureMgmtUri -Method PUT -Headers $requestHeader -Body $body
    ConvertTo-Json -InputObject $ProjectStatusResponse
}

Function Print-Output( $ProjectStatusGetResponse ){
    $tName = 'Task Name: {0}' -f $ProjectStatusGetResponse.name
    $tType = "Task Type: {0}" -f $ProjectStatusGetResponse.properties.taskType
    $tStatus = "Task State: {0}" -f $ProjectStatusGetResponse.properties.state
    if ($action -eq "get" -and $tStatus -eq "Running") {
        $tLevel = "Database State: {0}" -f $ProjectStatusGetResponse.properties.output[1].migrationState
    }
    Write-Output ""
    Write-Output "--------------------------------------------------------------------------"
    Write-Output $tName
    Write-Output $tType
    Write-Output $tStatus    
    Write-Output $tLevel
    Write-Output "--------------------------------------------------------------------------"
    Write-Output ""
}

Function Create-Activity($subscriptionId, $resourceGroup, $location, $serviceName, $projectName, $taskName, $database, $sourceserver, $sourceuser, $sourcepassword, $targetserver, $targetuser, $targetpassword) {
    $authResult = Set-CachedCredentials

    # Create Authorization Header
    $authHeader = $authResult.CreateAuthorizationHeader()

    # Set HTTP request headers to include Authorization header
    $requestHeader = @{
        "x-ms-version" = " 2017-04-15-privatepreview";
        "Content-Type" = "application/json; charset=utf-8"
        "Authorization" = $authHeader
        }

    #Create activity
    $azureMgmtUri = 'https://management.azure.com/subscriptions/' + $subscriptionId + '/resourceGroups/' + $resourceGroup + '/providers/Microsoft.DataMigration/services/' + $serviceName + '/projects/' + $projectName + '/tasks/' + $taskName + '?api-version=2017-11-15-privatepreview&$expand=output()';

    $body = '{"location":"' + $location + '","properties":{"taskType":"Migrate.PostgreSql.AzureDbForPostgreSql.Sync","input":{"selectedDatabases":[{"targetDatabaseName":"' + $database + '","makeSourceDbReadOnly":false,"schemaName":"%","tableMap":null,"id":"0ef16383-d380-4d8f-985a-4be686b24fd2","name":"' + $database + '"}],"targetConnectionInfo":{"serverName":"' + $targetserver + '","port":5432,"userName":"' + $targetuser + '","password":"' + $targetpassword + '","dataSource":null,"machineName":null,"authentication":"None","shouldImpersonate":false,"encryptConnection":false,"additionalSettings":null,"platform":"SqlOnPrem","trustServerCertificate":false,"sslCa":null},"sourceConnectionInfo":{"serverName":"' + $sourceserver + '","port":5432,"userName":"' + $sourceuser + '","password":"' + $sourcepassword + '","dataSource":null,"machineName":null,"authentication":"None","shouldImpersonate":false,"encryptConnection":false,"additionalSettings":null,"platform":"SqlOnPrem","trustServerCertificate":true,"sslCa":null}}}}';
    $ProjectStatusResponse = Invoke-RestMethod -Uri $azureMgmtUri -Method PUT -Headers $requestHeader -Body $body 
    Print-Output $ProjectStatusResponse           
}

Function Get-Activity($subscriptionId, $resourceGroup, $location, $serviceName, $projectName, $taskName) {
    $authResult = Set-CachedCredentials

    # Create Authorization Header
    $authHeader = $authResult.CreateAuthorizationHeader()

    # Set HTTP request headers to include Authorization header
    $requestHeader = @{
        "x-ms-version" = " 2017-04-15-privatepreview";
        "Content-Type" = "application/json; charset=utf-8"
        "Authorization" = $authHeader
        }

    #Create activity
    $azureMgmtUri = 'https://management.azure.com/subscriptions/' + $subscriptionId + '/resourceGroups/' + $resourceGroup + '/providers/Microsoft.DataMigration/services/' + $serviceName + '/projects/' + $projectName + '/tasks/' + $taskName + '?api-version=2017-11-15-privatepreview&$expand=output()';

    $ProjectStatusGetResponse = Invoke-RestMethod -Uri $azureMgmtUri -Method GET -Headers $requestHeader
           
     Print-Output $ProjectStatusGetResponse
     # ConvertTo-Json -InputObject $ProjectStatusGetResponse
}

Function Cancel-Activity($subscriptionId, $resourceGroup, $location, $serviceName, $projectName, $taskName) {
    $authResult = Set-CachedCredentials

    # Create Authorization Header
    $authHeader = $authResult.CreateAuthorizationHeader()

    # Set HTTP request headers to include Authorization header
    $requestHeader = @{
        "x-ms-version" = " 2017-04-15-privatepreview";
        "Content-Type" = "application/json; charset=utf-8"
        "Authorization" = $authHeader
        }

    #Create activity
    $azureMgmtUri = 'https://management.azure.com/subscriptions/' + $subscriptionId + '/resourceGroups/' + $resourceGroup + '/providers/Microsoft.DataMigration/services/' + $serviceName + '/projects/' + $projectName + '/tasks/' + $taskName + '/cancel?api-version=2017-11-15-privatepreview&$expand=output()';
    $ProjectStatusGetResponse = Invoke-RestMethod -Uri $azureMgmtUri -Method POST -Headers $requestHeader
           
    Print-Output $ProjectStatusGetResponse
}

Function Delete-Activity($subscriptionId, $resourceGroup, $location, $serviceName, $projectName, $taskName) {
    $authResult = Set-CachedCredentials

    # Create Authorization Header
    $authHeader = $authResult.CreateAuthorizationHeader()

    # Set HTTP request headers to include Authorization header
    $requestHeader = @{
        "x-ms-version" = " 2017-04-15-privatepreview";
        "Content-Type" = "application/json; charset=utf-8"
        "Authorization" = $authHeader
        }

    #Create activity
    $azureMgmtUri = 'https://management.azure.com/subscriptions/' + $subscriptionId + '/resourceGroups/' + $resourceGroup + '/providers/Microsoft.DataMigration/services/' + $serviceName + '/projects/' + $projectName + '/tasks/' + $taskName + '?api-version=2017-11-15-privatepreview&$expand=output()';

    $ProjectStatusGetResponse = Invoke-RestMethod -Uri $azureMgmtUri -Method DELETE -Headers $requestHeader               
}
