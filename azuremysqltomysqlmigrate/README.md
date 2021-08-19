# Migrating Azure Databases for MySQLfrom One server to other

The script applies to both **Azure Database for MySQL - Single Server and Azure Database for MySQL – Flexible Server**

You can use this script for the following Azure Database for MySQL migration scenarios:
* Single Server to Flexible Server
* Flexible Server to Single Server
* Single Server to Single Server
* Flexible Server to Flexible Server

## Functionalities Provided by the script 

### Version 1.6
1. Ability to migrate the following scenario (1. Single-To-Flexible,2.Flexible-To-Flexible,3.Single-To-Single,4.Flexible-To-Single)
2. Ability to check and act based on target server is Private or public Network Access
3. Ability to check the pre-req required Azure CLI ,MySQL client mysqldump are there..
4. Abiity to check the connectivity
5. Ability to  read variables from a parameter file -Json format
6. Ability to log to console and to file for debug purpose
7. Ability to clean the files used
8. Ability to migrate all databases
9. Ability to migrate the firewall rules when we have public access
10. Ability to migrate users to the default password 
11. Ability to migrate the Grants 
12. Ability to migrate Server parameters which were changed from default
13. Ability to validate the migrate the Database basic and creating validation report
14. Ability to select databases which you would like to migrate 
15. Ability to select the phase of migration 1) Validation (Yes\No) 2)Firewall Migration (Yes\No) 3)Server Parameter (Yes\No) 4)User Migration
16. Dynamic SSL switch to make it work in both old and new versions of MySQL client. 
17. Ability to decide the state of the source database during and post migration (Read_only or Read_write)


## How to Use the script azuremysqlmigrate.sh

* Download the scritp file  : **wget -L https://raw.githubusercontent.com/Azure/azure-mysql/master/azuremysqltomysqlmigrate/azuremysqlmigfinal.sh**
* Download the parameter file : **wget -L https://raw.githubusercontent.com/Azure/azure-mysql/master/azuremysqltomysqlmigrate/migrateparameter.json**
* Make the script Executable : **chmod +x azuremysqlmigfinal.sh**
* Edit the Parameter file and provide the migration details 
* Edit the *migrateparameter.json*  (Or create a paramater file with this template)
* Run the scripts : **./azuremysqlmigfinal.sh** *Parameterfilename*
> If you dont specify the parameter file name it will check the default file migrateparameter.json is same folder



