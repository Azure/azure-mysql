# Azure Database for MySQL (App Migration Secure)

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-mysql%2Fmaster%2FMigrationGuide%2Farm-templates%2FExampleWithMigrationSecure%2Ftemplate.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png" />
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-mysql%2Fmaster%2FMigrationGuide%2Farm-templates%2FExampleWithMigrationSecure%2Ftemplate.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This ARM template deploys [Azure Database for MySQL Server](https://docs.microsoft.com/en-us/azure/mysql/overview) with supported Azure resources to perform a sample application and MySQL migration.

In addition to the app services, an App Gateway with proper Virtual Network Hub and spoke topology is configured.  The App is also configured with private endpoints that the App Gateway is aware of to route traffic.  This prevents direct access to the MySQL driven web application.
