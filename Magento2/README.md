# Deploy a Magento open-source LAMP-stack e-commerce app on Azure with one click!

## Introduction
[Magento Open Source](https://business.adobe.com/products/magento/open-source.html) is a free and flexible e-commerce platform that allows you to create and manage online stores. This Azure Resource Manager JSON template provides a easy one-click method to deploy Magento on Azure using following Azure services to provide an optimal experience of hosting Magento on Azure with tight integrations.

* [Azure Resource Manager (ARM) templates](https://learn.microsoft.com/en-in/azure/azure-resource-manager/templates/overview) 
* [Azure Kubernetes Service (AKS) documentation](https://learn.microsoft.com/en-us/azure/aks/)
* [Azure Container Registry documentation](https://learn.microsoft.com/en-us/azure/container-registry/)
* [Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/)
* [Azure networking](https://learn.microsoft.com/en-us/azure/networking/)
* [Azure Virtual Network](https://learn.microsoft.com/en-us/azure/virtual-network/)
* [Azure DNS](https://learn.microsoft.com/en-us/azure/dns/)
* [Azure Private Link](https://learn.microsoft.com/en-us/azure/private-link/)
* [Azure NetApp Files](https://learn.microsoft.com/en-us/azure/azure-netapp-files/)
* [Azure Virtual Machine Scale Sets](https://learn.microsoft.com/en-us/azure/virtual-machine-scale-sets/)
* [Azure Database for MySQL - Flexible Server](https://learn.microsoft.com/en-us/azure/mysql/)
* [Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/)

This solution includes automation to deploy in a single-click all the required AKS infrastructure, database server and deploy Magento and dependent components in AKS.

The ARM template will create and deploy the following resources in your Azure account:

1. A virtual network with a subnet and a network security group.
2. A secret that stores the Magento Open-Source credentials and encryption keys.
3. A public IP address and a load balancer.
4. An Azure Database for MySQL – Flexible Server PaaS database for Magento Open Source, the best place for MySQL on Azure.
5. A storage account for Magento Open-Source media files. A persistent volume claim and a storage class that provide persistent storage for Magento Open-Source data.
6. Azure Content Delivery Network (CDN) to store static files, CSS, scripts, images. (Requires SSL/TLS enabled)
7. A deployment of Azure Kubernetes Services (AKS) with:
    *  A specified number of pods that run Magento Open-Source containers.
    * An Elasticsearch subchart that deploys an Elasticsearch cluster for Magento Open-Source search functionality.
    * A Redis subchart that deploys a Redis server for Magento Open-Source session and page caching.
8. A service that exposes the Magento Open-Source pods to the internet.

<p align="center">
  <img src="images/magento2-architecture.png" alt="Magento2 solution architecture"/>
</p>

## Deployment Steps
The following pre-requisites need to be configured before deploying the ARM template. 
1. Create a Resource group in your Azure Subscription to deploy the Magento solution. Please note that a second resource group is created for AKS specific infrastructure deployment with the resource group name as prefix that you created.
2. Get your authentication keys from [Commerce Marketplace](https://commercemarketplace.adobe.com/). You may need to register and generate the public and private keys. Follow Adobe document: [Get your authentication keys | Adobe Commerce](https://experienceleague.adobe.com/en/docs/commerce-operations/installation-guide/prerequisites/authentication-keys)
3. Run the following commands on Azure CLI to create RBAC Role and assign necessary permissions for running the automated script to configure AKS: 

```
az login (Does not apply to Azure CLI in Azure Portal)

az account set --subscription <Subscription_Id/Name> (Applicable if multiple subscription associated with Azure account)

az ad sp create-for-rbac --name magento2 --role "Azure Kubernetes Service Contributor Role" --scopes /subscriptions/<Subscription_Id>/resourceGroups/<Resource_Group> 
 
az role assignment create --assignee <AppId> --role "CDN Profile Contributor" --scope /subscriptions/<Subscription_Id>/resourceGroups/<Resource_Group> 

az role assignment create --assignee <AppId> --role "Virtual Machine Contributor" --scope /subscriptions/<Subscription_Id>/resourceGroups/<Resource_Group> 
```

Save the output from the above command as you need to provide this information to the template when deploying in later steps filling required information in ARM deployment.

## HTTPS using SSL 
If using SSL encryption for users to reach the Magento E-Commerce site via HTTPS: 
1. Create key vault in the same resource group created initially.
2. Import your certificates for TLS to the same key vault.

**NOTE -** SSL/TLS is required to use Azure CDN, otherwise turn it off during deployment.

## Deploy the ARM template
To deploy this ARM template, open the Azure CLI, and then run the following command: 
```
az deployment group create --resource-group <ResourceGroupName> --template-file azuredeploy.json 
``` 
See [this article](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/common-deployment-errors) for troubleshooting the deployment errors. 
Alternatively, the following button will allow you to deploy the APM template from Azure portal: [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-mysql%2Frefs%2Fheads%2Fmaster%2FMagento2%2Fazuredeploy.json)

## Minimum required inputs for Deployment
The following configuration values are must for the deployment, some of which you will obtain in the pre-requisite steps:

| Configuration | Description |
| ------------- | ----------- |
| Service Principal App ID | The Service Principal App ID from the output of the Azure CLI commands to create the RBAC roles in the earlier steps. |
| Service Principal Password |	The Service Principal App Password from the output of the Azure CLI commands to create the RBAC roles in the earlier steps. |
| Composer Username | The public key from the authentication access keys generated at Commerce Marketplace. |
| Composer Password | The private key from the authentication access keys generated at Commerce Marketplace. |
| Magento Admin Password | The password for the Magento administrator. |
| MYSQL Administrator Password | Admin password for Azure Database for MySQL Flexible Server. |
| VM Admin Password | Admin password for the temporary virtual machine used for AKS setup. |
| Magento Admin Email | The email address for the Magento admin. |
| Storage Account Name | The unique name for Azure Storage Account to host Magento content. |

## Advanced Customization (Optional)
The following configuration uses default values suitable for most simple configurations, do customize based on the application requirements.

| Configuration | Default | Description |
| ------------- | :-----: | ----------- |
| Magento Admin Username | magentoadmin | The username you want for the Magento administrator. |
| MYSQL Administrator Login | mysqlmagento | Admin username for Azure Database for MySQL Flexible Server. |
| MYSQL Compute SKU | Standard_D2ads_v5 | The name of the SKU for Azure Database for MySQL Flexible Servers, e.g. Standard_D32ds_v4. For a complete list refer: Service tiers. Ensure the SKU capacity is available in the region before selecting from the MySQL Flexible server create page. |
| Kubernetes System Node Pool Count | 1 | Specifies the number of agents (VMs) to host docker containers. Allowed values must be in the range of 1 to 1000 (inclusive). The default value is 1. |
| Kubernetes System Node Pool VM Size | Standard_DS2_v2 | Specifies the VM size of nodes in the node pool. |
| Magento File Share Quota GB | 100 | Size of the azure file share in GB. This quota is for the Magento media and static files. The minimum share size is 100 GB. |
| Elasticsearch File Share Quota GB | 100 | Size of the azure file share in GB. This quota is for the Elasticsearch. The minimum share size is 100 GB. |
| VM Size | Standard_DS1_v2 | Choose the compute size for virtual machine. |
| VM Admin Username | magentovmadmin | Admin username for the temporary virtual machine used for AKS setup. |
| Redis Cache | Enabled | Set this to true for enabling Redis database caching for the Magento application. |
| Varnish Cache | Enabled | Set this to true for enabling Varnish HTML content cache for Magento application. |
| Azure CDN | Disabled | Set this to true for enabling Azure Content Delivery Network (CDN) for static, CSS and scripts for Magento application. (This requires SSL/TLS enabled). |
| SSL Encryption TLS | Disabled | Enable SSL/TLS encryption for users reaching Magento web application over HTTPS. |
| Resource Name Prefix | magento | Provide a prefix for generating resource names as part of the Magento solution. |
| Key Vault Name | blank | The name of the key vault (created in same resource group as pre-requisite) to access certificate for SSL / TLS configuration." |
| Certificate Name | blank | Provide the respective certificate name in key vault for SSL/TLS configuration. |
| External FQDN | blank | Provide the external Fully Qualified DNS Name (FQDN) that you have obtained via any web hosting to map to the Magento site. |
| MYSQL Database Name | magento | The name of the database to store Magento data. |
| MYSQL Server Edition | GeneralPurpose | The Azure Database for MySQL compute tier. High availability is available only for General Purpose and Business Critical Tiers. |
| MYSQL Version | 8.0.21 | The MySQL version to be used in Azure Database for MySQL. |
| MYSQL Availability Zone | blank | The Azure availability zone for the Azure Database for MySQL server, ensure that the zone exists in respective region. (If you don't have a preference, leave this setting blank.) |
| MYSQL High Availability | Disabled | High availability mode for Azure Database for MySQL server: Disabled, Same-Zone, or Zone-Redundant. |
| MYSQL Standby Availability Zone | blank | Availability zone of the High availability standby server, ensure that the zone exists in the respective region. (Leave blank for No Preference). Add this value if HA is enabled. |
| MYSQL Storage Size GB | 20 | Azure database for MySQL storage size in GiB. Storage is used for the database files, temporary files, transaction logs, and the MySQL server logs. In all compute tiers, the minimum storage supported is 20 GiB and maximum is 16 TiB (16384 GiB). It is not required to overprovision storage as by default storage online auto-grow is enabled. |
| MYSQL Backup Retention Days | 7 | By default, backups are retained for 7 days. The minimum retention period is 1 day and the maximum retention period is 35 days. |
| MYSQL Geo Redundant Backup | Disabled | Enable Geo-redundant backups for Azure Database for MySQL Flexible Server. |
| Enable Secret Rotation | true | Accepts value true/false. If true, periodically updates the pod mount and Kubernetes Secret with the latest content from external secrets store. |
| Rotation Poll Interval | 2m | If enableSecretRotation is true, this setting specifies the secret rotation poll interval duration. This duration can be adjusted based on how frequently the mounted contents for all pods and Kubernetes secrets need to be resynced to the latest. |
| Storage Account SKU | Premium_LRS | The SKU of the storage account. |
| SKU Azure CDN | Standard_Microsoft | Provide the profile SKU for the Azure CDN. |

## Cleanup resources
To remove this deployment simply remove the following Resource groups:
1. Resource group created as part of AKS infra whose name starts with resource group created in initial pre-requisite step.
2. Resource group created in initial pre-requisite step. 

#### Code of Conduct
This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information, see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact opencode@microsoft.com with any additional questions or comments. 

#### Legal Notices
Microsoft and any contributors grant you a license to the Microsoft documentation and other content in this repository under the [Creative Commons Attribution 4.0 International Public License](https://creativecommons.org/licenses/by/4.0/legalcode), see the [LICENSE](https://github.com/Azure/azure-mysql/blob/master/Magento2/LICENSE) file, and grant you a license to any code in the repository under the [MIT License](https://opensource.org/licenses/MIT) file. 

Microsoft, Windows, Microsoft Azure and/or other Microsoft products and services referenced in the documentation may be either trademarks or registered trademarks of Microsoft in the United States and/or other countries. The licenses for this project do not grant you rights to use any Microsoft names, logos, or trademarks. Microsoft's general trademark guidelines can be found at [Microsoft Trademarks](https://github.com/Azure/azure-mysql/blob/master/Magento/LICENSE). 

Privacy information can be found at [Privacy at Microsoft](https://privacy.microsoft.com/). Microsoft and any contributors reserve all others rights, whether under their respective copyrights, patents, or trademarks, whether by implication, estoppel or otherwise.