<#
.SYNOPSIS
    Script to run an offline MySQL migration scenario via DMS.
.Description
    Script that allows MySQL offline migrations to be run within DMS.  This script uses the DMS Rest APIs and has been tested
    with version 5.7 of the Azure "az" module and PowerShell version 7.1.
    As part of the caller $global:currentSubscriptionId should be set to the target subscription
.PARAMETER Location
    Location name where the resource group needs to be created if not existing 
.PARAMETER ResourceGroupName
    Name of the resource group that contains the DMS resource.
.PARAMETER ServiceName
    Name of the DMS resource.
.PARAMETER VirtualNetworkName
    Name of the VNET instance to be used if DMS service needs to be created
.PARAMETER SubnetName
    Name of the subnet in the VNET to be used if DMS service needs to be created
.PARAMETER ProjectName
    Name of the project where the migration will be created.
.PARAMETER TaskName
    Name of the migration task to be created.
.PARAMETER SourceDatabaseName
    Name of the database on the source that will be migrated.
.PARAMETER SourceServerName
    Name or IP address of the source MySQL server.
.PARAMETER SourceUserName
    Name of the user on the source that has access to the database.
.PARAMETER SourcePassword
    Password for the user on the source that has access to the database.
.PARAMETER TargetDatabaseName
    Name of the target database on the target MySQL server.
.PARAMETER TargetServerName
    Name or IP address of the target MySQL server.
.PARAMETER TargetUserName
    Name of the user on the target that has access to the database.
.PARAMETER TargetPassword
    Password for the user on the target that has access to the database.
.PARAMETER IncludeTables
    Optional setting that specifies the tables to be included for migration from the source.
    Default value is NULL which implies include all tables from source.
.PARAMETER ExcludeTables
    Optional setting that specifies the tables to be excluded for migration from the source.
    Default value is NULL which implies exclude no tables from source.
    ExcludeTables list has higher priority than IncludeTables list.
.PARAMETER DesiredRangesCount
    Optional setting that configures the maximum number of parallel reads on tables located on the source database.
.PARAMETER MaxBatchSizeKb
    Optional setting that configures that size of the largest batch that will be committed to the target server.
.PARAMETER MinBatchRows
    Optional setting that configures the minimum number of rows in each batch written to the target.
.PARAMETER PrepareDatabaseForBulkImportTaskCount
    Optional setting that configures the number of databases that will be prepared for migration in parallel.
.PARAMETER PrepareTableForBulkImportTaskCount
    Optional setting that configures the number of tables that will be prepared for migration in parallel.
.PARAMETER QueryTableDataRangeTaskCount
    Optional setting that configures the number of threads available to read ranges on the source.
.PARAMETER WriteDataRangeBatchTaskCount
    Optional setting that configures the number of threads available to write batches to the target.
.PARAMETER MaxBatchCacheSizeMb
    Optional setting that configures how much memory will be used to cache batches in memory before
    reads on the source are throttled.
.PARAMETER ThrottleQueryTableDataRangeTaskAtAvailableMemoryMb
    Optional setting that configures the amount of available memory at which point reads on the source
    will be throttled.
.PARAMETER ThrottleQueryTableDataRangeTaskAtBatchCount
    Optional setting that configures the number of batches cached in memory that will trigger read
    throttling on the source.
.PARAMETER DelayProgressUpdatesInStorageInterval
    Optional setting that configures the delay between updates of result objects in Azure Table Storage.
.EXAMPLE
    Connect-AzAccount
    Set-AzContext -Subscription DMSTest
    .\Invoke-DmsMySqlOffline.ps1 -SubscriptionName mySubscription `
        -Location "westus2" `
        -ResourceGroupName MySqlMigrationServiceGroup `
        -ServiceName MySqlMigrationService `
        -VirtualNetworkName myVnet `
        -SubnetName mySubnet `
        -ProjectName MySqlMigrations `
        -TaskName db1Migration `
        -SourceDatabaseName db1 `
        -SourceServerName SourceMySqlServer `
        -SourceUserName dms `
        -SourcePassword <password> `
        -TargetDatabaseName db1 `
        -TargetServerName TargetMySqlServer.mysql.database.azure.com `
        -TargetUserName dms@TargetMySqlServer `
        -TargetPassword <password> `
        -DesiredRangesCount 4 `
        -MaxBatchSizeKb 4096 `
        -QueryTableDataRangeTaskCount 12 `
        -WriteDataRangeBatchTaskCount 12 `
        -DelayProgressUpdatesInStorageInterval "00:00:10" `
        -IncludeTables db1.tbl1, db1.tbl2
#>
param(
    [Parameter(Mandatory = $true)]
    [string] $Location,
    [Parameter(Mandatory = $true)]
    [string] $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string] $ServiceName,
    [Parameter(Mandatory = $true)]
    [string] $VirtualNetworkName,
    [Parameter(Mandatory = $true)]
    [string] $SubnetName,
    [Parameter(Mandatory = $true)]
    [string] $ProjectName,
    [Parameter(Mandatory = $true)]
    [string] $TaskName,
    [Parameter(Mandatory = $true)]
    [string] $SourceDatabaseName,
    [Parameter(Mandatory = $true)]
    [string] $SourceServerName,
    [Parameter(Mandatory = $true)]
    [string] $SourceUserName,
    [Parameter(Mandatory = $true)]
    [securestring] $SourcePassword,
    [Parameter(Mandatory = $true)]
    [string] $TargetDatabaseName,
    [Parameter(Mandatory = $true)]
    [string] $TargetServerName,
    [Parameter(Mandatory = $true)]
    [string] $TargetUserName,
    [Parameter(Mandatory = $true)]
    [securestring] $TargetPassword,
    # Optional table settings
    [Parameter(Mandatory = $false)]
    [string[]] $IncludeTables = $null,
    [Parameter(Mandatory = $false)]
    [string[]] $ExcludeTables = $null,
    # Partitioning settings
    [Parameter(Mandatory = $false)]
    [object] $DesiredRangesCount = $null,
    [Parameter(Mandatory = $false)]
    [object] $MaxBatchSizeKb = $null,
    [Parameter(Mandatory = $false)]
    [object] $MinBatchRows = $null,
    # Task count settings
    [Parameter(Mandatory = $false)]
    [object] $PrepareDatabaseForBulkImportTaskCount = $null,
    [Parameter(Mandatory = $false)]
    [object] $PrepareTableForBulkImportTaskCount = $null,
    [Parameter(Mandatory = $false)]
    [object] $QueryTableDataRangeTaskCount = $null,
    [Parameter(Mandatory = $false)]
    [object] $WriteDataRangeBatchTaskCount = $null,
    # Batch cache settings
    [Parameter(Mandatory = $false)]
    [object] $MaxBatchCacheSizeMb = $null,
    [Parameter(Mandatory = $false)]
    [object] $ThrottleQueryTableDataRangeTaskAtAvailableMemoryMb = $null,
    [Parameter(Mandatory = $false)]
    [object] $ThrottleQueryTableDataRangeTaskAtBatchCount = $null,
    # Performance settings
    [Parameter(Mandatory = $false)]
    [object] $DelayProgressUpdatesInStorageInterval = $null
)

function LogMessage([string] $Message, [bool] $IsProcessing = $false) {
    if ($IsProcessing) {
        Write-Host "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss"): $Message" -ForegroundColor Yellow
    }
    else {
        Write-Host "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss"): $Message" -ForegroundColor Green
    }    
}

function InitConnection(
    [string] $ServerName,
    [string] $UserName,
    [securestring] $Password) {
    $connectionInfo = @{
        "dataSource"             = "";
        "serverName"             = "";
        "port"                   = 3306;
        "userName"               = "";
        "password"               = "";
        "authentication"         = "SqlAuthentication";
        "encryptConnection"      = $true;
        "trustServerCertificate" = $true;
        "additionalSettings"     = "";
        "type"                   = "MySqlConnectionInfo" 
    }

    $connectionInfo.dataSource = $ServerName;
    $connectionInfo.serverName = $ServerName;
    $connectionInfo.userName = $UserName;
    $connectionInfo.password = (ConvertFrom-SecureString -AsPlainText $password).ToString();
    $connectionInfo;
}

function RunScenario([object] $MigrationService, 
    [object] $MigrationProject, 
    [string] $ScenarioTaskName, 
    [object] $TaskProperties, 
    [bool] $WaitForScenario = $true) {
    # Check if the scenario task already exists, if so remove it
    LogMessage -Message "Removing scenario if already exists..." -IsProcessing $true
    Remove-AzDataMigrationTask `
        -ResourceGroupName $MigrationService.ResourceGroupName `
        -ServiceName $MigrationService.Name `
        -ProjectName $MigrationProject.Name `
        -TaskName $ScenarioTaskName `
        -Force;

    # Start the new scenario task using the provided properties
    LogMessage -Message "Initializing scenario..." -IsProcessing $true
    New-AzResource `
        -ApiVersion 2018-03-31-preview `
        -Location $MigrationService.Location `
        -ResourceId "/subscriptions/$($global:currentSubscriptionId)/resourceGroups/$($MigrationService.ResourceGroupName)/providers/Microsoft.DataMigration/services/$($MigrationService.Name)/projects/$($MigrationProject.Name)/tasks/$($ScenarioTaskName)" `
        -Properties $TaskProperties `
        -Force | Out-Null;
    
    LogMessage -Message "Waiting for $ScenarioTaskName scenario to complete..." -IsProcessing $true
    if ($WaitForScenario) {
        $progressCounter = 0;
        do {
            if ($null -ne $scenarioTask) {
                Start-Sleep 10;
            }

            # Get calls can time out and will return a cancellation exception in that case
            $scenarioTask = Get-AzDataMigrationTask `
                -ResourceGroupName $MigrationService.ResourceGroupName `
                -ServiceName $MigrationService.Name `
                -ProjectName $MigrationProject.Name `
                -TaskName $ScenarioTaskName `
                -Expand `
                -ErrorAction Ignore;

            Write-Progress -Activity "Scenario Run $ScenarioTaskName  (Marquee Progress Bar)" `
                -Status $scenarioTask.ProjectTask.Properties.State `
                -PercentComplete $progressCounter
            
            $progressCounter += 10;
            if ($progressCounter -gt 100) { $progressCounter = 10 }
        }
        while (($null -eq $scenarioTask) -or ($scenarioTask.ProjectTask.Properties.State -eq "Running") -or ($scenarioTask.ProjectTask.Properties.State -eq "Queued"))
    }
    Write-Progress -Activity "Scenario Run $ScenarioTaskName" `
        -Status $scenarioTask.ProjectTask.Properties.State `
        -Completed
                 
    # Now get it using REST APIs so we can expand the output  
    LogMessage -Message "Getting expanded task results ..." -IsProcessing $true  
    $psToken = (Get-AzAccessToken -ResourceUrl https://management.azure.com).Token;
    $token = ConvertTo-SecureString -String $psToken -AsPlainText -Force;
    $taskResource = Invoke-RestMethod `
        -Method GET `
        -Uri "https://management.azure.com$($scenarioTask.ProjectTask.Id)?api-version=2018-03-31-preview&`$expand=output" `
        -ContentType "application/json" `
        -Authentication Bearer `
        -Token $token;
    
    $taskResource.properties;
}

function AddOptionalSetting($optionalAgentSettings, $settingName, $settingValue) {
    # If no value specified for the setting, don't bother adding it to the input
    if ($null -eq $settingValue) {
        return;
    }

    # Add a new property to the JSON object to capture the setting which will be customized
    $optionalAgentSettings | add-member -MemberType NoteProperty -Name $settingName -Value $settingValue
}

<#==================================Main Script===============================#>
# Get the details of resource group
$resourceGroup = Get-AzResourceGroup -Name $ResourceGroupName
if (-not($resourceGroup)) {
    LogMessage -Message "Creating resource group $ResourceGroupName..." -IsProcessing $true
    $resourceGroup = New-AzResourceGroup -Name $ResourceGroupName -Location $Location
    LogMessage -Message "Created resource group - $($resourceGroup.ResourceId)."
}
else { LogMessage -Message "Resource group $ResourceGroupName exists." }

<#====DMS Service====#>
# Capture details from the current connection and get a reference to the DMS service
$dmsServiceResourceId = "/subscriptions/$($global:currentSubscriptionId)/resourceGroups/$ResourceGroupName/providers/Microsoft.DataMigration/services/$ServiceName"
$dmsService = Get-AzResource -ResourceId $dmsServiceResourceId -ErrorAction SilentlyContinue

# Create Azure DMS service if not existing
# Possible values for SKU currently are Standard_1vCore,Standard_2vCores,Standard_4vCores,Premium_4vCores
if (-not($dmsService)) {   
    $virtualNetwork = Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VirtualNetworkName
    if (-not ($virtualNetwork)) { throw "ERROR: Virtual Network $VirtualNetworkName does not exists" }

    $subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $virtualNetwork -Name $SubnetName
    if (-not ($subnet)) { throw "ERROR: Virtual Network $VirtualNetworkName does not contains Subnet $SubnetName" }

    LogMessage -Message "Creating Azure Data Migration Service $ServiceName..." -IsProcessing $true
    $dmsService = New-AzDataMigrationService `
        -ResourceGroupName $ResourceGroupName `
        -Name $ServiceName `
        -Location $resourceGroup.Location `
        -Sku Premium_4vCores `
        -VirtualSubnetId $Subnet.Id
    
    $dmsService = Get-AzResource -ResourceId $dmsServiceResourceId
    LogMessage -Message "Created Azure Data Migration Service - $($dmsService.ResourceId)."
}
else { LogMessage -Message "Azure Data Migration Service $ServiceName exists." }

<#====DMS Project====#>
# Capture details from the current connection and get a reference to the DMS project
$dmsProjectResourceId = "/subscriptions/$($global:currentSubscriptionId)/resourceGroups/$($dmsService.ResourceGroupName)/providers/Microsoft.DataMigration/services/$($dmsService.Name)/projects/$projectName"
$dmsProject = Get-AzResource -ResourceId $dmsProjectResourceId -ErrorAction SilentlyContinue

# Create Azure DMS Project if not existing
if (-not($dmsProject)) {
    LogMessage -Message "Creating Azure DMS project $projectName for MySQL migration ..." -IsProcessing $true

    $newProjectProperties = @{"sourcePlatform" = "MySQL"; "targetPlatform" = "AzureDbForMySQL" }
    $dmsProject = New-AzResource `
        -ApiVersion 2018-03-31-preview `
        -Location $dmsService.Location `
        -ResourceId $dmsProjectResourceId `
        -Properties $newProjectProperties `
        -Force;
        
    LogMessage -Message "Created Azure DMS project $projectName - $($dmsProject.ResourceId)."
}
else { LogMessage -Message "Azure DMS project $projectName exists." }

<#====Connection Info====#>
# Initialize the source and target database server connections
LogMessage -Message "Initializing source and target connection objects ..." -IsProcessing $true
$sourceConnInfo = InitConnection `
    $SourceServerName `
    $SourceUserName `
    $SourcePassword;

$targetConnInfo = InitConnection `
    $TargetServerName `
    $TargetUserName `
    $TargetPassword;

LogMessage -Message "Source and target connection object initialization complete."

<#====Table Listing====#>
# Run scenario to get the tables from the target database to build the migration table mapping
# Create the get table task properties by initializing the connection and database name
$getTablesTaskProperties = @{
    "input"    = @{
        "connectionInfo"    = $null;
        "selectedDatabases" = $null;
    };
    "taskType" = "GetUserTablesMySql";
};

LogMessage -Message "Running scenario to get the list of tables from the target database..." -IsProcessing $true
$getTablesTaskProperties.input.connectionInfo = $targetConnInfo;
$getTablesTaskProperties.input.selectedDatabases = @($TargetDatabaseName);
# Create a name for the task
$getTableTaskName = "$($TargetDatabaseName)GetUserTables"
# Get the list of tables from the source
$getTargetTablesTask = RunScenario -MigrationService $dmsService `
    -MigrationProject $dmsProject `
    -ScenarioTaskName $getTableTaskName `
    -TaskProperties $getTablesTaskProperties;

if (-not ($getTargetTablesTask)) { throw "ERROR: Could not get target database $TargetDatabaseName table information." }
LogMessage -Message "List of tables from the target database acquired."

LogMessage -Message "Running scenario to get the list of tables from the source database..." -IsProcessing $true
$getTablesTaskProperties.input.connectionInfo = $sourceConnInfo;
$getTablesTaskProperties.input.selectedDatabases = @($SourceDatabaseName);
# Create a name for the task
$getTableTaskName = "$($SourceDatabaseName)GetUserTables"
# Get the list of tables from the source
$getSourceTablesTask = RunScenario -MigrationService $dmsService `
    -MigrationProject $dmsProject `
    -ScenarioTaskName $getTableTaskName `
    -TaskProperties $getTablesTaskProperties;

if (-not ($getSourceTablesTask)) { throw "ERROR: Could not get source database $SourceDatabaseName table information." }
LogMessage -Message "List of tables from the source database acquired."

<#====Table Mapping====#>
# Create the source to target table map
LogMessage -Message "Creating the table map based on the user input and database table information ..." `
    -IsProcessing $true

$targetTables = $getTargetTablesTask.Output.DatabasesToTables."$TargetDatabaseName";
$sourceTables = $getSourceTablesTask.Output.DatabasesToTables."$SourceDatabaseName";
$tableMap = New-Object 'system.collections.generic.dictionary[string,string]';

$schemaPrefixLength = $($SourceDatabaseName + ".").Length;
$tableMappingError = $false
foreach ($srcTable in $sourceTables) {
    # Removing the database name prefix from the table name so that comparison
    # can be done in cases where database name given are different
    $tableName = $srcTable.Name.Substring($schemaPrefixLength, `
            $srcTable.Name.Length - $schemaPrefixLength)

    # In case the table is part of exclusion list then ignore the table
    if ($null -ne $ExcludeTables -and $ExcludeTables -contains $srcTable.Name) {
        continue;
    }

    # Either the include list is null or the table is part of the include list then add it in the mapping
    if ($null -eq $IncludeTables -or $IncludeTables -contains $srcTable.Name) {
        # Check if the table exists in the target. If not then log TABLE MAPPING ERROR
        if (-not ($targetTables | Where-Object { $_.name -ieq "$($TargetDatabaseName).$tableName" })) {
            $tableMappingError = $true
            Write-Host "TABLE MAPPING ERROR: $($targetTables.name) does not exists in target." -ForegroundColor Red
            continue;
        }  

        $tableMap.Add("$($SourceDatabaseName).$tableName", "$($TargetDatabaseName).$tableName");
    }  
}

# In case of any table mapping errors identified, throw an error and stop the process
if ($tableMappingError) { throw "ERROR: One or more table mapping errors were identified. Please see previous messages." }
# In case no tables are in the mapping then throw error
if ($tableMap.Count -le 0) { throw "ERROR: Could not create table mapping." }
LogMessage -Message "Migration table mapping created for $($tableMap.Count) tables."

<#====Create Task====#>
# Create and run the migration scenario based on the connections
# and the table mapping
$offlineMigTaskProperties = @{
    "input"    = @{
        "sourceConnectionInfo"  = $null;
        "targetConnectionInfo"  = $null;
        "selectedDatabases"     = $null;
        "optionalAgentSettings" = @{
            "EnableCacheBatchesInMemory"         = $true;
            "DisableIncrementalRowStatusUpdates" = $true;
        };
        "startedOn"             = $null;
    };
    "taskType" = "Migrate.MySql.AzureDbForMySql";
};
$offlineSelectedDatabase = @{
    "name"               = $null;
    "targetDatabaseName" = $null;
    "tableMap"           = $null;
};

LogMessage -Message "Preparing migration scenario configuration ..." -IsProcessing $true

# Select the database to be migrated
$offlineSelectedDatabase.name = $SourceDatabaseName;
$offlineSelectedDatabase.tableMap = New-Object PSObject -Property $tableMap;
$offlineSelectedDatabase.targetDatabaseName = $TargetDatabaseName;

# Set connection info and the database mapping
$offlineMigTaskProperties.input.sourceConnectionInfo = $sourceConnInfo;
$offlineMigTaskProperties.input.targetConnectionInfo = $targetConnInfo;
$offlineMigTaskProperties.input.selectedDatabases = @($offlineSelectedDatabase);
$offlineMigTaskProperties.input.startedOn = [System.DateTimeOffset]::UtcNow.ToString("O");

<#====Configure Task====#>
# Setting optional parameters from fine tuning the data transfer rate during migration
# DEFAULT values for all the configurations is $null
LogMessage -Message "Adding optional migration performance tuning configuration ..." -IsProcessing $true
# Set any optional settings in the input based on parameters to this cmdlet
AddOptionalSetting $offlineMigTaskProperties.input.optionalAgentSettings "DesiredRangesCount" $DesiredRangesCount;
AddOptionalSetting $offlineMigTaskProperties.input.optionalAgentSettings "MaxBatchSizeKb" $MaxBatchSizeKb;
AddOptionalSetting $offlineMigTaskProperties.input.optionalAgentSettings "MinBatchRows" $MinBatchRows;
AddOptionalSetting $offlineMigTaskProperties.input.optionalAgentSettings "PrepareDatabaseForBulkImportTaskCount" $PrepareDatabaseForBulkImportTaskCount;
AddOptionalSetting $offlineMigTaskProperties.input.optionalAgentSettings "PrepareTableForBulkImportTaskCount" $PrepareTableForBulkImportTaskCount;
AddOptionalSetting $offlineMigTaskProperties.input.optionalAgentSettings "QueryTableDataRangeTaskCount" $QueryTableDataRangeTaskCount;
AddOptionalSetting $offlineMigTaskProperties.input.optionalAgentSettings "WriteDataRangeBatchTaskCount" $WriteDataRangeBatchTaskCount;
AddOptionalSetting $offlineMigTaskProperties.input.optionalAgentSettings "MaxBatchCacheSizeMb" $MaxBatchCacheSizeMb;
AddOptionalSetting $offlineMigTaskProperties.input.optionalAgentSettings "ThrottleQueryTableDataRangeTaskAtAvailableMemoryMb" $ThrottleQueryTableDataRangeTaskAtAvailableMemoryMb;
AddOptionalSetting $offlineMigTaskProperties.input.optionalAgentSettings "ThrottleQueryTableDataRangeTaskAtBatchCount" $ThrottleQueryTableDataRangeTaskAtBatchCount;
AddOptionalSetting $offlineMigTaskProperties.input.optionalAgentSettings "DelayProgressUpdatesInStorageInterval" $DelayProgressUpdatesInStorageInterval;

<#====Run and Monitor====#>
# Running the migration scenario
LogMessage -Message "Running data migration scenario ..." -IsProcessing $true
$summary = @{
    "SourceServer"   = $SourceServerName;
    "SourceDatabase" = $SourceDatabaseName;
    "TargetServer"   = $TargetServerName;
    "TargetDatabase" = $TargetDatabaseName;
    "TableCount"     = $tableMap.Count;
    "StartedOn"      = $offlineMigTaskProperties.input.startedOn;
}

Write-Host "Job Summary:" -ForegroundColor Yellow
Write-Host $(ConvertTo-Json $summary) -ForegroundColor Yellow

$migrationResult = RunScenario -MigrationService $dmsService `
    -MigrationProject $dmsProject `
    -ScenarioTaskName $TaskName `
    -TaskProperties $offlineMigTaskProperties

LogMessage -Message "Migration completed with status - $($migrationResult.state)";

<#====Error detection and extraction====#>
$dbLevelResult = $migrationResult.output | Where-Object { $_.resultType -eq "DatabaseLevelOutput" } 
$migrationLevelResult = $migrationResult.output | Where-Object { $_.resultType -eq "MigrationLevelOutput" }
if ($dbLevelResult.exceptionsAndWarnings) {
    Write-Host "Following database errors were captured: $($dbLevelResult.exceptionsAndWarnings)" -ForegroundColor Red
}
if ($migrationLevelResult.exceptionsAndWarnings) {
    Write-Host "Following migration errors were captured: $($migrationLevelResult.exceptionsAndWarnings)" -ForegroundColor Red
}
if ($migrationResult.errors.details) {
    Write-Host "Following task level migration errors were captured: $($migrationResult.errors.details)" -ForegroundColor Red
}

return $migrationResult