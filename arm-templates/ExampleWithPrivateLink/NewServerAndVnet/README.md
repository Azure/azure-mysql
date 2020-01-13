# Azure Private Link for Azure Database for MySQL Server


<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-mysql%2Fmaster%2Farm-templates%2FExampleWithPrivateLink%2FNewServerAndVnet%2Ftemplate.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png" />
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-mysql%2Fmaster%2Farm-templates%2FExampleWithPrivateLink%2FNewServerAndVnet%2Ftemplate.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This ARM template creates the following resources : 

1. [VNET](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview)
integrated with a [Private DNS Zone](https://docs.microsoft.com/en-us/azure/dns/private-dns-overview). 

2. Windows Client VM inside the above VNET.

3. [Azure Database for MySQL Server](https://docs.microsoft.com/en-us/azure/mysql/overview)

4. [Azure Private Endpoint](https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-overview). 
   MySQL Server can be accessed from within the VNET using the Private Endpoint. 


## Azure Private Link

![Architecture](https://raw.githubusercontent.com/Azure/azure-mysql/master/arm-templates/ExampleWithPrivateLink/NewServerAndVnet/privatelink.jpg)

## Private Endpoint Connectivity Architecture

![PrivateEndpoint](https://raw.githubusercontent.com/Azure/azure-mysql/master/arm-templates/ExampleWithPrivateLink/NewServerAndVnet/architecture.jpg)


## Deployment and Connectivity

Click on the **Deploy to Azure** button above to deploy the ARM Template **parentTemplate.json**

Once you have deployed the ARM Template **successfully without any errors**, you will be able to connect to the MySQL Server from the Client VM using mysql command. 

For hostname in the mysql command, we can use either the private IP address or the FQDN since the VNET is integrated with Private DNS Zone and we have an A record pointing the FQDN to the Private IP address of the MySQL Server. 

Remote Desktop into the Client VM, install mysql commandline and run the following command to connect to the MySQL Server securely : 

```
mysql --host={privateIPAddress} --port=3306 --database={your_database} --user={your_username} --ssl-mode=REQUIRED --password={your_password}
```

Example : 

```
mysql --host=10.1.2.4 --port=3306 --database=mysql --user=mysqluser@mysqlserver --ssl-mode=REQUIRED --password=mypassword
```

```
mysql --host=mysqlserver.mysql.database.azure.com  --port=3306 --database=mysql --user=mysqluser@mysqlserver --ssl-mode=REQUIRED --password=mypassword
```

**NOTE** : nslookup mysqlserver.mysql.database.azure.com will resolve to the private IP address 10.1.2.4 


## Contribution 


If you have trouble deploying the ARM Template, please let us know by opening an issue: https://github.com/Azure/azure-mysql/issues

Feel free to contribute any updates or bug fixes by creating a pull request: https://github.com/Azure/azure-mysql/pulls

Thank you!

## References 

[Introducing Private Link for Azure Database for MySQL Server](https://techcommunity.microsoft.com/t5/azure-database-for-mysql/introducing-private-link-for-azure-database-for-mysql/ba-p/1093244)


