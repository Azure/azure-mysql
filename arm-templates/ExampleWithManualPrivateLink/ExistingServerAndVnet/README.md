# Azure Private Link for Azure Database for MySQL Server

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-mysql%2Fmaster%2Farm-templates%2FExampleWithManualPrivateLink%2FExistingServerAndVnet%2Ftemplate.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png" />
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-mysql%2Fmaster%2Farm-templates%2FExampleWithManualPrivateLink%2FExistingServerAndVnet%2Ftemplate.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This ARM template deploys [Azure Private Endpoint](https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-overview) for an existing [Azure Database for MySQL Server](https://docs.microsoft.com/en-us/azure/mysql/overview) in an existing [VNET](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview)

[Introducing Private Link for Azure Database for MySQL Server](https://techcommunity.microsoft.com/t5/azure-database-for-mysql/introducing-private-link-for-azure-database-for-mysql/ba-p/1093244)

[Approval Process](https://docs.microsoft.com/en-us/azure/mysql/concepts-data-access-security-private-link#approval-process)

![Architecture](https://raw.githubusercontent.com/Azure/azure-mysql/master/arm-templates/ExampleWithManualPrivateLink/ExistingServerAndVnet/architecture.jpg)