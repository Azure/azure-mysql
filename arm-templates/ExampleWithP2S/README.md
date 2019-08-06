# Secure connectivity from On-Premise to Azure Database for MySQL using Point-to-Site Gateway

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-mysql%2Fmaster%2Farm-templates%2FExampleWithP2S%2Ftemplate.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png" />
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-mysql%2Fmaster%2Farm-templates%2FExampleWithP2S%2Ftemplate.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

<br/>

This ARM template deploys [Azure Database for MySQL Server](https://docs.microsoft.com/en-us/azure/mysql/overview) and [Ubuntu VM](http://releases.ubuntu.com/19.04/) in a VNET. Ubuntu VM is configured with [NGINX](http://nginx.org/) to act as TCP Proxy and forwards all traffic on port 3306 to the MySQL Server. This configuration is useful for Secure On-Prem Connectivity to Azure Database for MySQL Server. 

## Architecture

![Architecture](https://raw.githubusercontent.com/Azure/azure-mysql/master/arm-templates/ExampleWithP2S/secure_connectivity.jpg)


## Deployment and Connectivity

Click on the **Deploy to Azure** button above to deploy the ARM Template **template.json**

Once you have deployed the ARM Template **successfully without any errors**, you will be able to see the mysqlCommand as part of Deployment Outputs

![Deployment Outputs](https://raw.githubusercontent.com/Azure/azure-mysql/master/arm-templates/ExampleWithP2S/output.jpg)


**mysqlCommand** provides the mysql command to connect the MySQL Server 


```
mysql "host={privateIPAddress} port=3306 dbname={your_database} user={your_username} sslmode=require"
```

Example : 

```
mysql "host=10.3.0.5 port=3306 dbname=postgres user=mysqluser@p2sdemoMYSQL sslmode=require"
```

## Contribution 


If you have trouble deploying the ARM Template, please let us know by opening an issue: https://github.com/Azure/azure-mysql/issues

Feel free to contribute any updates or bug fixes by creating a pull request: https://github.com/Azure/azure-mysql/pulls

Thank you!

## References 

[Configure a Point-to-Site connection to a VNet using native Azure certificate authentication: Azure portal](https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-point-to-site-resource-manager-portal)

[Use Virtual Network service endpoints and rules for Azure Database for MySQL - Single Server](https://docs.microsoft.com/en-us/azure/mysql/concepts-data-access-and-security-vnet)

[Module ngx_http_upstream_module](http://nginx.org/en/docs/http/ngx_http_upstream_module.html)

