New-AzureDmsActivity `
    -serviceName "BuildDemoPG" `
    -projectName "BuildDemoPG" `
    -taskName "StarWarsPG1" `
    -sourceserver "138.91.123.10" `
    -sourceuser "postgres" `
    -database "inventory" `
    -targetserver "builddemotarget.postgres.database.azure.com" `
    -targetuser "dms@builddemotarget" 
   