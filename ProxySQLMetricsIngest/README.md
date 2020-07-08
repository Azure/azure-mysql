# Ingest ProxySQL Metrics into the Azure Monitor Log Analytics Workspace

ProxySQL have rich internal functioning metrics which could be accessed from its stats database through the Admin interface, and the stored metrics are the snapshot of a particular point of time when you select the metric table. When troubleshooting the problem, we need to review and accumulate the historical metrics data with powerful query functions like [Azure Monitor Kusto Queries](https://docs.microsoft.com/en-us/azure/azure-monitor/log-query/query-language) to help understand the overall status. In this blog, we will introduce how to post the metrics to Azure Monitor Log Analytics Workspace and leverage the powerful Kusto query language to monitor the ProxySQL statistics metrics.
## Access the ProxySQL Metrics for Monitoring:
1. Connect the ProxySQL Admin interface through any client using MySQL protocol with the admin credential like below:
```bash
 mysql -u admin -padmin -h 127.0.0.1 -P6032
```
2. Access the statistics metrics by select query like below example:
```SQL
select Client_Connections_aborted from stats.stats_mysql_global
```
3. Please refer the metrics detail in https://proxysql.com/documentation/stats-statistics/, there are 18 stats tables storing important monitoring data viz the front end and backend connections, query digest, GTID, prepared statements and etc.
> *Note*: ProxySQL is an open source community tool. It is supported by Microsoft on a best effort basis. In order to get production support with authoritative guidance, you can evaluate and reach out to ProxySQL Product support.
## Ingest the Metrics to external monitoring tool – Azure Monitor:
1.  Assume you have installed ProxySQL on a Linux VM already, as the Admin interface is only allowed to access locally, we need to run the ingestion code side by side on the same VM. The ingestion sample code will query the ProxySQL stats metrics then post the data to the Logical Workspace in a regular 1-minute interval.
2. Provision a [Log Analytics Workspace](https://docs.microsoft.com/en-us/azure/azure-monitor/learn/quick-create-workspace) to store the posted metrics. The Ingestion sample code performs POST Azure Monitor custom log through HTTP REST API: [Link](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/data-collector-api)
3. The ingestion sample code is developed with .NET Core 3.1, and you could check out from the [GitHub repo](https://github.com/Azure/azure-mysql/tree/master/ProxySQLMetricsIngest)
## Detail usage instructions about the sample ingesting code:
1. Install .NET Core on the Linux VM where ProxySQL is located.
Refer to https://docs.microsoft.com/dotnet/core/install/linux-package-manager-ubuntu-1804
```bash
wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo add-apt-repository universe
sudo apt-get update
sudo apt-get install apt-transport-https
sudo apt-get update
sudo apt-get install dotnet-sdk-3.1
```
2. Get the Custom ID and Shared Key of the Log Analytics Workspace
```text
1)	In the Azure portal, locate your Log Analytics workspace.
2)	Select Advanced Settings and then Connected Sources.
3)	To the right of Workspace ID, select the copy icon, and then paste the ID as the value of the Customer ID input for the sample application input.
4)	To the right of Primary Key, select the copy icon, and then paste the ID as the value of the Shared Key input for the sample application input.
```
3. Checkout the sample code and run:
```bash
git clone https://github.com/Azure/azure-mysql
cd ProxySQLMetricsIngest/
dotnet build
sudo dotnet run
```
Here are some details about the sample:

    1) It is a console application which will ask for the input of the connection string for ProxySQL Admin Interface, (Log Workspace) custom ID and Shared key.
    2) The sample currently register a 1-minute timer to periodically access the ProxySQL stats tables through MySQL protocol and post data into the Log Analytics Workspace
    3) Each ProxySQL stats table name would be used as the Custom Log Type Name, and the Log Analytics will automatically add _CL suffix to generate the complete Custom Log Type Name. For example, the stats table stats_memory_metrics will become stats_memroy_metrics_CL in the Custom Logs list. 
    4) The sample code also post the error logs in /var/lib/proxysql/proxysql.log to the Log Analytics Workspace as Custom Log Type: PSLogs_CL, to get the file read permission, please execute “sudo dotnet run”.

4. Use Kusto query in Log Analytics Workspace to operate the ProxySQL metrics data.
Please be noticed that all the ProxySQL stats table values are set to string, so need convert it to number in Kusto query.

>Disclaimer: This sample code is available AS IS with no warranties and support from Microsoft. Please raise an issue in Github if you encounter any issues and I will try our best to address it.

>If you have trouble setting up ProxySQL on Azure Database for MySQL, please contact the Azure Database for MySQL team at [AskAzureDBforMySQL@service.microsoft.com](mailto:AskAzureDBforMySQL@service.microsoft.com)









