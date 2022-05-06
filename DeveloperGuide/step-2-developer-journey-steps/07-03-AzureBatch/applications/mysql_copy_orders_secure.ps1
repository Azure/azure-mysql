#install chocolaty
$item = get-item "C:\ProgramData\chocolatey\choco.exe" -ea silentlycontinue;

if (!$item)
{
    write-host "Installing Chocolaty";

    $env:chocolateyUseWindowsCompression = 'true'
    Set-ExecutionPolicy Bypass -Scope Process -Force; 
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")

choco feature enable -n allowGlobalConfirmation

#install azure powershell
choco install az.powershell

#install mysql
choco install mysql-cli

#install .net connector
choco install mysql-connector -y
#Install-package MySQL.Data

#get environment variables
$vaultName = $env:Batch_VaultName;
$thumbprint = $env:Batch_Thumbprint;
$applicationId = $env:Batch_AppId;
$TenantId = $env:Batch_TenantId;

#login to azure using certificatre
Connect-AzAccount -ServicePrincipal -CertificateThumbprint $Thumbprint -ApplicationId $ApplicationId -TenantId $TenantId

[void][System.Reflection.Assembly]::LoadWithPartialName("MySQL.Data") 

$server = Get-AzKeyVaultSecret -VaultName $vaultName -Name "DB-SERVER" -AsPlainText;
$database = Get-AzKeyVaultSecret -VaultName $vaultName -Name "DB-DATABASE" -AsPlainText;
$user = Get-AzKeyVaultSecret -VaultName $vaultName -Name "DB-USER" -AsPlainText;
$password = Get-AzKeyVaultSecret -VaultName $vaultName -Name "DB-PASSWORD" -AsPlainText;

#run the queries...
$myconnection = New-Object MySQL.Data.MySqlClient.MySqlConnection

$myconnection.ConnectionString = "server=$server;user id=$user;password=$password;database=$database;pooling=false"

$myconnection.Open()

$mycommand = New-Object MySQL.Data.MySqlClient.MySqlCommand
$mycommand.Connection = $myconnection
$mycommand.CommandText = "SHOW DATABASES"
$myreader = $mycommand.ExecuteReader();

$res = "";

while($myreader.Read())
{ 
    $res += $myreader.GetString(0) 
}

$myconnection.Close()

#write out to a file...
add-content "data.txt" $res;

#output to the stdout...
write-host $res;