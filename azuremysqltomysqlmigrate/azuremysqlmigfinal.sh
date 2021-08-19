#!/bin/bash

#Version 1.6
#--Ability to migrate the following scenario (1. Single-To-Flexible,2.Flexible-To-Flexible,3.Single-To-Single,4.Flexible-To-Single)
#--Ability to check and act based on target server is Private or public Network Access
#--Ability to check the pre-req required Azure CLI ,MySQL client mysqldump are there..
#--Abiity to check the connectivity
#--Ability to  read variables from a parameter file -Json format
#--Ability to log to console and to file for debug purpose
#--Ability to clean the files used
#--Ability to migrate all databases
#--Ability to migrate the firewall rules when we have public access
#--Ability to migrate users to the default password 
#--Ability to migrate the Grants 
#--Ability to migrate Server parameters which were changed from default
#--Ability to validate the migrate the Database basic and creating validation report
#--Ability to select databases which you would like to migrate 
#--Ability to select the phase of migration 1) Validation (Yes\No) 2)Firewall Migration (Yes\No) 3)Server Parameter (Yes\No)
#--Dynamic SSL switch to make it work in both old and new versions of MySQL client. 


###################Parameter file default######################################
if [ -z "$1" ]
then
export MY_PARAMETERFILE="migrateparameter.json" #Name of the paramater file
else
MY_PARAMETERFILE=$1
fi 

if ! [[ -f "$MY_PARAMETERFILE" ]]; then
    echo "Parameter file does not exist $MY_PARAMETERFILE exists."
	exit 1
fi

#########For Logging################################
NOW=$(date +"%m%d%Y%H%M%S")
export MY_LOGFILE="migration"$NOW".log"
export MY_MYSQLDUMPLOG="mysqldump"$NOW".log"
export MY_MYSQLVALIDATIONREPORT="validation_report"$NOW".txt"
#############################################################
echo $(date) : "Migration scenario $MY_MYSCENARIO starting" >$MY_LOGFILE
echo "Migration scenario $MY_MYSCENARIO starting ..Log File :$MY_LOGFILE " 
echo $(date) : "Checking Pre-requisites  Azure CLI ,MySQL client mysqldump are there.." >>$MY_LOGFILE
echo "Checking Pre-requisites  Azure CLI ,MySQL client, mysqldump and jq are there.." 
echo  -e "\e[1;35mThe Parameter file used is $MY_PARAMETERFILE\e[0m" 
echo $(date) : "The Parameter file used is $MY_PARAMETERFILE:"  >>$MY_LOGFILE

#############################Pre-req Check#########################################
# Prerequisites - Install Azure CLI and mysql-client package
if ! [ -x "$(command -v az)" ]; then
  echo 'Error: azure cli is not installed. Please install from https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest' >&2
  echo $(date) : 'Error: azure cli is not installed. Please install from https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest' >>$MY_LOGFILE
  exit 1
fi

if ! [ -x "$(command -v mysqldump)" ]; then
  echo 'Error: mysqldump command does not exist. Please install from https://dev.mysql.com/downloads/mysql/' >&2
  echo $(date) :  'Error: mysqldump command does not exist. Please install from https://dev.mysql.com/downloads/mysql/' >>$MY_LOGFILE
  exit 1
fi

if ! [ -x "$(command -v mysql)" ]; then
  echo 'Error: mysql command does not exist. Please install from https://dev.mysql.com/downloads/mysql/' >&2
  echo $(date) : 'Error: mysqldump command does not exist. Please install from https://dev.mysql.com/downloads/mysql/' >>$MY_LOGFILE
  exit 1
fi

if ! [ -x "$(command -v jq)" ]; then
  echo 'Error: jq is not installed. Please install from https://www.howtoinstall.me/ubuntu/18-04/jq/ >&2
  echo 'Error: jq is not installed. Please install from https://www.howtoinstall.me/ubuntu/18-04/jq/ >>$MY_LOGFILE
  exit 1
fi

if ! [ -x "$(command -v cmp)" ]; then
  echo 'Error: cmp is not installed. Please install cmp https://command-not-found.com/cmp' >&2
  echo $(date) : 'Error: cmp is not installed. Please install cmp https://command-not-found.com/cmp' >>$MY_LOGFILE
  exit 1
fi


######################################SSL Switch###############################################################################

sslcheck=$(mysql --help | grep "ssl-mode")
if [[  -z $sslcheck ]]
then
export sslswitch="--ssl=TRUE"
else 
export sslswitch="--ssl-mode=required"
fi


#############################Parameter Export#######################################################################


export MY_MYSCENARIO=`jq -r .parameters.MY_MYSCENARIO.value $MY_PARAMETERFILE`
export MY_SOURCESUBSCRIPTION=`jq -r .parameters.MY_SOURCESUBSCRIPTION.value $MY_PARAMETERFILE`
export MY_TARGETSUBSCRIPTION=`jq -r .parameters.MY_TARGETSUBSCRIPTION.value $MY_PARAMETERFILE`
export MY_SOURCEDBSERVER=`jq -r .parameters.MY_SOURCEDBSERVER.value $MY_PARAMETERFILE`
export MY_TARGETDBSERVER=`jq -r .parameters.MY_TARGETDBSERVER.value $MY_PARAMETERFILE`
export MY_SOURCERG=`jq -r .parameters.MY_SOURCERG.value $MY_PARAMETERFILE`
export MY_TARGETRG=`jq -r .parameters.MY_TARGETRG.value $MY_PARAMETERFILE`
export MY_SOURCEUSER=`jq -r .parameters.MY_SOURCEUSER.value $MY_PARAMETERFILE`
export MY_SOURCEUSERPWD=`jq -r .parameters.MY_SOURCEUSERPWD.value $MY_PARAMETERFILE`
export MY_TARGETUSER=`jq -r .parameters.MY_TARGETUSER.value $MY_PARAMETERFILE`
export MY_TARGETUSERPWD=`jq -r .parameters.MY_TARGETUSERPWD.value $MY_PARAMETERFILE`
export MY_MYSQLDEFAULTPWD=`jq -r .parameters.MY_MYSQLDEFAULTPWD.value $MY_PARAMETERFILE`

export MY_MYDBSELECTION=`jq -r .parameters.MY_MYDBSELECTION.value $MY_PARAMETERFILE`
export MY_MYSELECTIONVALIDATE=`jq -r .parameters.MY_MYSELECTIONVALIDATE.value $MY_PARAMETERFILE`
export MY_MYSELECTIONFIREWALLRULE=`jq -r .parameters.MY_MYSELECTIONFIREWALLRULE.value $MY_PARAMETERFILE`
export MY_MYSELECTIONSERVERPARAMETER=`jq -r .parameters.MY_MYSELECTIONSERVERPARAMETER.value $MY_PARAMETERFILE`
export MY_MYSELECTIONUSER=`jq -r .parameters.MY_MYSELECTIONUSER.value $MY_PARAMETERFILE`


export MY_MYSELECTIONROSTART=`jq -r .parameters.MY_MYSELECTIONROSTART.value $MY_PARAMETERFILE`
export MY_MYSELECTIONROAFTER=`jq -r .parameters.MY_MYSELECTIONROAFTER.value $MY_PARAMETERFILE`


echo "=================================================" >>$MY_LOGFILE
echo "Selected Scenario  :" $MY_MYSCENARIO >>$MY_LOGFILE
echo "Source Subscription :" $MY_SOURCESUBSCRIPTION >>$MY_LOGFILE
echo "Target Subscription :" $MY_TARGETSUBSCRIPTION >>$MY_LOGFILE
echo "Source DB Server  :" $MY_SOURCEDBSERVER >>$MY_LOGFILE
echo "Target DB server  :" $MY_TARGETDBSERVER >>$MY_LOGFILE
echo "Source Resource Group :" $MY_SOURCERG >>$MY_LOGFILE
echo "Target Resource Group :" $MY_TARGETRG >>$MY_LOGFILE
echo "Source User Name :" $MY_SOURCEUSER >>$MY_LOGFILE
echo "Target User Name :" $MY_TARGETUSER >>$MY_LOGFILE

####comment this in case you dont want your password to be displayed on screen
echo "Source User Name :" $MY_SOURCEUSERPWD >>$MY_LOGFILE
echo "Target password  :"$MY_TARGETUSERPWD >>$MY_LOGFILE
echo "Default Passoword for migrated users  :" $MY_MYSQLDEFAULTPWD >>$MY_LOGFILE
########################################################################

echo "================================================="
echo "Selected Scenario  :" $MY_MYSCENARIO
echo "Source Subscription :" $MY_SOURCESUBSCRIPTION
echo "Target Subscription :" $MY_TARGETSUBSCRIPTION
echo "Source DB Server  :" $MY_SOURCEDBSERVER
echo "Target DB server  :" $MY_TARGETDBSERVER
echo "Source Resource Group :" $MY_SOURCERG
echo "Target Resource Group :" $MY_TARGETRG
echo "Source User Name :" $MY_SOURCEUSER
echo "Target User Name :" $MY_TARGETUSER

####comment this in case you dont want your password to be displayed on screen
echo "Source User Name :" $MY_SOURCEUSERPWD
echo "Target password  :"$MY_TARGETUSERPWD
echo "Default Password for migrated users  :" $MY_MYSQLDEFAULTPWD
########################################################################

#####################################Flow-Selection#####################
 if [ "$MY_MYDBSELECTION" = "ALL" ]
then 
echo -e "\e[1;36m You have selected to migrate all databases in the server $MY_SOURCEDBSERVER \e[0m"
echo "You have selected to migrate all databases in the server $MY_SOURCEDBSERVER" >>$MY_LOGFILE
else 
echo -e "\e[1;33mYou have selected to migrate the following databases  $MY_MYDBSELECTION in server $MY_SOURCEDBSERVER \e[0m"
echo "You have selected to migrate the following databases  $MY_MYDBSELECTION in server $MY_SOURCEDBSERVER" >>$MY_LOGFILE
fi

 if [ "$MY_MYSELECTIONVALIDATE" = "NO" ]
then 
echo -e "\e[1;36m Validation report will be generated \e[0m" 
echo "Validation report will be generated" >>$MY_LOGFILE
else 
echo -e  "\e[1;33m Validation report will be skipped \e[0m"
echo "Validation report will be skipped" >>$MY_LOGFILE
fi

if [ "$MY_MYSELECTIONFIREWALLRULE" = "NO" ]
then 
echo "Firewall rule will be migrated"  >>$MY_LOGFILE
echo -e "\e[1;36m Firewall rule will be migrated \e[0m"
else 
echo "Firewall rule migration will be skipped " >>$MY_LOGFILE
echo -e "\e[1;33m Firewall rule migration will be skipped \e[0m"
fi

if [ "$MY_MYSELECTIONSERVERPARAMETER" = "NO" ]
then 
echo "Changed Server Parameter  will be migrated" >>$MY_LOGFILE
echo -e  "\e[1;36m Changed Server Parameter  will be migrated \e[0m"
else 
echo "Server Parameter migration will be skipped " >>$MY_LOGFILE
echo -e "\e[1;33m Server Parameter migration will be skipped\e[0m"
fi


if [ "$MY_MYSELECTIONUSER" = "NO" ]
then 
echo "USER migration will be performed to default password "  >>$MY_LOGFILE
echo -e "\e[1;36m USER migration will be performed to default password \e[0m"
else 
echo "USER migration will be skipped" >>$MY_LOGFILE
echo -e "\e[1;33m USER migration will be skipped \e[0m"
fi


if [ "$MY_MYSELECTIONROSTART" = "NO" ]
then 
echo "The source server will be set to Read-only while migrating"  >>$MY_LOGFILE
echo -e "\e[1;36m The source server will be set to Read-only while migrating \e[0m"
else 
echo "The source server will be in Read-write mode while migrating" >>$MY_LOGFILE
echo -e "\e[1;33m The source server will be in Read-write mode while migrating\e[0m"
fi


if [ "$MY_MYSELECTIONROAFTER" = "NO" ]
then 
echo "The source server will be set to Read-Write after migrating"  >>$MY_LOGFILE
echo -e "\e[1;36m The source server will be set to Read-Write after migrating \e[0m"
else 
echo "The source server will be in Read-Only for Cutover post migrating" >>$MY_LOGFILE
echo -e "\e[1;33m The source server will be in Read-Only for Cutover post migrating \e[0m"
fi


echo "================================================="  >>$MY_LOGFILE
echo "================================================="
echo -e "\e[1;32m Confirm if displayed details are correct\e[0m "
read -p "Do you want to Continue (Y/N)? " -n 1 -r
echo    
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo -e "\e[1;31m Edit your Parameter (json file) : $MY_PARAMETERFILE with correct the details....\e[0m"
    exit 1
fi




#Connect to source subscription
az account set --subscription "$MY_SOURCESUBSCRIPTION"
echo "Checking if Target server is Private access if yes firewall rules migration will be skipped" 
echo $(date) :"Checking if Target server is Private access if yes firewall rules migration will be skipped" >>$MY_LOGFILE
############Check if the Target server is Private access if yes skip the firewall rule migration step###########
case $MY_MYSCENARIO in
        "Single-To-Flexible")
        mydbaccess=$(az mysql flexible-server show --resource-group $MY_TARGETRG --name $MY_TARGETDBSERVER --subscription $MY_TARGETSUBSCRIPTION --output json)
        export MY_TARGACCESS=$(jq -r  '.network.publicNetworkAccess' <<< $mydbaccess)
        ;;
        "Flexible-To-Flexible")
        mydbaccess=$(az mysql flexible-server show --resource-group $MY_TARGETRG --name $MY_TARGETDBSERVER --subscription $MY_TARGETSUBSCRIPTION --output json)
        export MY_TARGACCESS=$(jq -r  '.network.publicNetworkAccess' <<< $mydbaccess)
        ;;
        "Single-To-Single")
         mydbaccess=$(az mysql server show --resource-group $MY_TARGETRG --name $MY_TARGETDBSERVER --subscription $MY_TARGETSUBSCRIPTION --output json)
        export MY_TARGACCESS=$(jq -r  '.publicNetworkAccess' <<< $mydbaccess)
        ;;
        "Flexible-To-Single")
        mydbaccess=$(az mysql server show --resource-group $MY_TARGETRG --name $MY_TARGETDBSERVER --subscription $MY_TARGETSUBSCRIPTION --output json)
        export MY_TARGACCESS=$(jq -r  '.publicNetworkAccess' <<< $mydbaccess)
        ;;
esac
if [ "$MY_MYSELECTIONFIREWALLRULE" = "NO" ]
then 
	if [ "$MY_TARGACCESS" = "Enabled" ]
	then 
		echo $(date) : "Server has Public Access migrating Firewall Rules.." >>$MY_LOGFILE
		echo "Server has Public Access migrating Firewall Rules.." 
		echo -e "\e[1;31m Creating Firewall rule to allow AllowAllWindowsAzureIps in Source -Remove this Post Migration if yo dont need this \e[0m "
		echo $(date) : "Creating Firewall rule to allow AllowAllWindowsAzureIps in Source  -Remove this Post Migration if yo dont need this" >>$MY_LOGFILE
		#To help connect to MySQL services from VM or Azure CLI adding firewall rule to allow all ip.You can also add individual IP here
		
		case $MY_MYSCENARIO in
			"Single-To-Flexible")
			az mysql server firewall-rule create --resource-group $MY_SOURCERG --server-name $MY_SOURCEDBSERVER --subscription $MY_SOURCESUBSCRIPTION --name "AllowAllWindowsAzureIps" --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0 >>$MY_LOGFILE
			;;
			"Flexible-To-Flexible")
			az mysql flexible-server firewall-rule create --resource-group $MY_SOURCERG --server-name $MY_SOURCEDBSERVER --subscription $MY_SOURCESUBSCRIPTION --rule-name "AllowAllWindowsAzureIps" --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0 >>$MY_LOGFILE
			;;
			"Single-To-Single")
			 az mysql server firewall-rule create --resource-group $MY_SOURCERG --server-name $MY_SOURCEDBSERVER --subscription $MY_SOURCESUBSCRIPTION --name "AllowAllWindowsAzureIps" --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0 >>$MY_LOGFILE
			;;
			"Flexible-To-Single")
			az mysql flexible-server firewall-rule create --resource-group $MY_SOURCERG --server-name $MY_SOURCEDBSERVER --subscription $MY_SOURCESUBSCRIPTION --rule-name "AllowAllWindowsAzureIps" --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0 >>$MY_LOGFILE
			;;
		esac
		
		
		##########################################################
		#Firewall Rule Migration
		##########################################################
		#Get the list of Firewall rules 
		echo $(date) : "Getting the list of Firewall rules From source" >>$MY_LOGFILE
		echo "Getting the list of Firewall rules From source" 
		
		case $MY_MYSCENARIO in
			"Single-To-Flexible")
			myrules=$(az mysql server firewall-rule list --resource-group $MY_SOURCERG --server-name $MY_SOURCEDBSERVER --subscription $MY_SOURCESUBSCRIPTION --output json)
			;;
			"Flexible-To-Flexible")
			myrules=$(az mysql flexible-server firewall-rule list --resource-group $MY_SOURCERG --server-name $MY_SOURCEDBSERVER --subscription $MY_SOURCESUBSCRIPTION --output json)
			;;
			"Single-To-Single")
			 myrules=$(az mysql server firewall-rule list --resource-group $MY_SOURCERG --server-name $MY_SOURCEDBSERVER --subscription $MY_SOURCESUBSCRIPTION --output json)
			;;
			"Flexible-To-Single")
			myrules=$(az mysql flexible-server firewall-rule list --resource-group $MY_SOURCERG --server-name $MY_SOURCEDBSERVER --subscription $MY_SOURCESUBSCRIPTION --output json)
			;;
		esac
		
		#Create the firewall rules in target server
		echo $(date) : "Migrating the Firewall rules to target" >>$MY_LOGFILE
		echo "Migrating the Firewall rules to target" 
		for i in $(echo $myrules | jq -c '.[]');do
			fname=$(jq -r '.name' <<< $i)
			fstartip=$(jq -r '.startIpAddress' <<< $i)
			fendip=$(jq -r '.endIpAddress' <<< $i)
			if [ "$fname" != "AllowAllWindowsAzureIps" ] 
			then
			export fname="Mig-"$fname
			fi
			echo $(date) : "Adding Firewall Rule on target server :$MY_TARGETDBSERVER (Name:$fname Start-ip-address:$fstartip End-ip-address:$fendip)" >>$MY_LOGFILE
			
			case $MY_MYSCENARIO in
			"Single-To-Flexible")
			az mysql flexible-server firewall-rule create --resource-group $MY_TARGETRG --name $MY_TARGETDBSERVER --subscription $MY_TARGETSUBSCRIPTION --rule-name $fname --start-ip-address $fstartip --end-ip-address $fendip >>$MY_LOGFILE
			;;
			"Flexible-To-Flexible")
			az mysql flexible-server firewall-rule create --resource-group $MY_TARGETRG --name $MY_TARGETDBSERVER --subscription $MY_TARGETSUBSCRIPTION --rule-name $fname --start-ip-address $fstartip --end-ip-address $fendip >>$MY_LOGFILE
			;;
			"Single-To-Single")
			 az mysql server firewall-rule create --resource-group $MY_TARGETRG --name $MY_TARGETDBSERVER --subscription $MY_TARGETSUBSCRIPTION --name $fname --start-ip-address $fstartip --end-ip-address $fendip >>$MY_LOGFILE
			;;
			"Flexible-To-Single")
			az mysql server firewall-rule create --resource-group $MY_TARGETRG --name $MY_TARGETDBSERVER --subscription $MY_TARGETSUBSCRIPTION --name $fname --start-ip-address $fstartip --end-ip-address $fendip >>$MY_LOGFILE
			;;
			esac
		done
	else 
	echo $(date) : "Server is Priavte access ..firewall rules migration skipped" >>$MY_LOGFILE
	echo "Server is Private access ..firewall rules migration skipped" 
	fi
fi
##########################################################
#connectivity test to source and target 
##########################################################
echo  "Testing connectivity to source server) $MY_SOURCEDBSERVER.mysql.database.azure.com......."
echo $(date) : "Testing connectivity to source server) $MY_SOURCEDBSERVER.mysql.database.azure.com......." >>$MY_LOGFILE
export MYSQL_PWD=$MY_SOURCEUSERPWD
a=$( mysql $sslswitch --host="$MY_SOURCEDBSERVER.mysql.database.azure.com" --user="$MY_SOURCEUSER"  -e "select version();")
if [ -z "$a" ]
then
        echo
        echo -e "\e[1;31m Failed to  connect........... \e[0m "
		echo $(date) : "Failed to connect to source sever $MY_SOURCEDBSERVER.mysql.database.azure.com......." >>$MY_LOGFILE
        echo -e "\e[1;36m Check the network connectivity from the source to the current vmand then continue...  \e[0m"
        echo -e "\e[1;36m Check running -- telnet "$MY_SOURCEDBSERVER.mysql.database.azure.com" 3306 -- to check network connectivity\e[0m"
        echo -e "\e[1;36m Confirm your username and password is correct....\e[0m"
        exit 1
    else
    echo -e "\e[1;32m Connected Successfully  to source server $MY_SOURCEDBSERVER.mysql.database.azure.com and MySQL Version Is: "$a"\e[0m"
	echo $(date) : "Connected Successfully  to source sever $MY_SOURCEDBSERVER.mysql.database.azure.com......." >>$MY_LOGFILE
fi

    echo  "Testing connectivity to target server $MY_TARGETDBSERVER.mysql.database.azure.com......."
	echo $(date) : "Testing connectivity to target server) $MY_TARGETDBSERVER.mysql.database.azure.com......." >>$MY_LOGFILE
export MYSQL_PWD=$MY_TARGETUSERPWD
a=$( mysql $sslswitch --host="$MY_TARGETDBSERVER.mysql.database.azure.com" --user="$MY_TARGETUSER"  -e "select version();")
if [ -z "$a" ]
then
        echo
        echo -e "\e[1;31m Failed to  connect........... \e[0m "
		echo $(date) : "Faield to connect to target sever $MY_TARGETDBSERVER.mysql.database.azure.com......." >>$MY_LOGFILE
        echo -e "\e[1;36m Check the network connectivity from the target to the current vmand then continue...  \e[0m"
        echo -e "\e[1;36m Check running -- telnet "$MY_TARGETDBSERVER.mysql.database.azure.com" 3306 -- to check network connectivity\e[0m"
            echo -e "\e[1;36m Confirm your username and password is correct....\e[0m"
        exit 1
    else
    echo -e "\e[1;32m Connected Successfully  to target server $MY_TARGETDBSERVER.mysql.database.azure.com and MySQL Version Is: "$a"\e[0m"
	echo $(date) : "Connected Successfully  to target sever $MY_TARGETDBSERVER.mysql.database.azure.com......." >>$MY_LOGFILE
fi               


##############################################################################################
#User Migration -The Password will be defaulted and then you would need to change password later.
##############################################################################################
if [ "$MY_MYSELECTIONUSER" = "NO" ]
then 
	echo $(date) : "User Migration Starting....." >>$MY_LOGFILE
	echo "User Migration Starting....." 
	# Remove dump file if it already exists
	[ -e $MY_SOURCEDBSERVER"_user.sql" ] && rm -f $MY_SOURCEDBSERVER"_user.sql" 
	echo $(date) : "Gettting the list of users (Azure Managed users will not be migrated )....." >>$MY_LOGFILE
	echo "Getting the list of users (Azure Managed users will not be migrated )....." 
	#Get the list of users created excluding azure users 
	export MYSQL_PWD=$MY_SOURCEUSERPWD
	mysql $sslswitch --host="$MY_SOURCEDBSERVER.mysql.database.azure.com" --user="$MY_SOURCEUSER" -e  "SELECT CONCAT('\'', user,'\'@\'', host, '\'') as username   FROM mysql.user WHERE user not in (select user from mysql.user  where length(user) = 16 and user like 'az%') and user != 'azure_superuser' AND user != 'azure_superuser' AND user != 'mysql.session' AND user != 'mysql.sys' AND user != '$MY_TARGETUSER';" mysql >$MY_SOURCEDBSERVER"_user.sql" 
	# Remove dump file if it already exists $MY_TARGETUSER
	[ -e $MY_SOURCEDBSERVER"_usergrant.sql" ] && rm -f $MY_SOURCEDBSERVER"_usergrant.sql" 
	#create file for user grants 
	echo $(date) : "Collecting information for User grants....." >>$MY_LOGFILE
	echo "Collecting information for User grants....." 
	while read line;
	do 
	if [ "$line" != "username" ] 
		then
	mysql $sslswitch --host="$MY_SOURCEDBSERVER.mysql.database.azure.com" --user="$MY_SOURCEUSER" -e "show grants for $line" >>$MY_LOGFILE
	fi
	done <$MY_SOURCEDBSERVER"_user.sql" >$MY_SOURCEDBSERVER"_usergrant.sql"

	#make the file SQL run ready 
	sed -i '/Grants for/d' $MY_SOURCEDBSERVER"_usergrant.sql"
	sed -i 's/$/;/' $MY_SOURCEDBSERVER"_usergrant.sql"
	echo $(date) : "Migrating user to Target server....." >>$MY_LOGFILE
	echo "Migrating user to Target server....." 
	#import users to target
	export MYSQL_PWD=$MY_TARGETUSERPWD
	#create users
	while read line;
	do 
	if [ "$line" != "username" ] 
		then
	mysql $sslswitch -v --host=$MY_TARGETDBSERVER".mysql.database.azure.com" --port=3306 --user=$MY_TARGETUSER -e "CREATE USER $line IDENTIFIED BY '$MY_MYSQLDEFAULTPWD'" >>$MY_LOGFILE
	fi
	done <$MY_SOURCEDBSERVER"_user.sql"
	#create  the user grants
	echo $(date) : "Creating Grants for users....." >>$MY_LOGFILE
	echo "Creating Grants for users....."
	mysql $sslswitch -v --host=$MY_TARGETDBSERVER".mysql.database.azure.com" --port=3306 --silent --user=$MY_TARGETUSER <$MY_SOURCEDBSERVER"_usergrant.sql" 
fi
##########################Server Parameter Migration###########################

echo $(date) : "Starting the Data Migration..." >>$MY_LOGFILE
echo "Starting the Data Migration..." 
##########################################################
#Data and Schema Migration
##########################################################
if [ "$MY_MYSELECTIONROSTART" = "NO" ]
then 
	echo $(date) : "Setting the source server to Read only " >>$MY_LOGFILE
	echo "Setting the source server to Read only " 
	#SET the source server to Read only 
		case $MY_MYSCENARIO in
				"Single-To-Flexible")
				az mysql server configuration set --name read_only --resource-group $MY_SOURCERG  --server $MY_SOURCEDBSERVER --subscription $MY_SOURCESUBSCRIPTION --value ON >>$MY_LOGFILE
				;;
				"Flexible-To-Flexible")
				az mysql flexible-server parameter set --resource-group $MY_SOURCERG  --server $MY_SOURCEDBSERVER --subscription $MY_SOURCESUBSCRIPTION --name read_only --value ON >>$MY_LOGFILE
				;;
				"Single-To-Single")
				az mysql server configuration set --name read_only --resource-group $MY_SOURCERG  --server $MY_SOURCEDBSERVER --subscription $MY_SOURCESUBSCRIPTION --value ON >>$MY_LOGFILE
				;;
				"Flexible-To-Single")
				az mysql flexible-server parameter set --resource-group $MY_SOURCERG  --server $MY_SOURCEDBSERVER --subscription $MY_SOURCESUBSCRIPTION --name read_only --value ON >>$MY_LOGFILE
				;;
		esac
fi
#get the list of user databases to be migrated
echo $(date) : "Getting List of User databases to be migrated" >>$MY_LOGFILE
echo "Getting List of User databases to be migrated" 
	case $MY_MYSCENARIO in
			"Single-To-Flexible")
			mydbs=$(az mysql db list --resource-group $MY_SOURCERG  --server $MY_SOURCEDBSERVER --subscription $MY_SOURCESUBSCRIPTION --query [].name --output tsv)
			;;
			"Flexible-To-Flexible")
			mydbs=$(az mysql flexible-server db list --resource-group $MY_SOURCERG  --server-name $MY_SOURCEDBSERVER --subscription $MY_SOURCESUBSCRIPTION --query [].name --output tsv)
			;;
			"Single-To-Single")
			mydbs=$(az mysql db list --resource-group $MY_SOURCERG  --server $MY_SOURCEDBSERVER --subscription $MY_SOURCESUBSCRIPTION --query [].name --output tsv)
			;;
			"Flexible-To-Single")
			mydbs=$(az mysql flexible-server db list --resource-group $MY_SOURCERG  --server-name $MY_SOURCEDBSERVER --subscription $MY_SOURCESUBSCRIPTION --query [].name --output tsv)
			;;
	esac

 if ! [ "$MY_MYDBSELECTION" = "ALL" ]
then 
	export mydbs=$MY_MYDBSELECTION
fi

for i in $(echo $mydbs | tr " " "\n")
do
if [ "$i" == "information_schema" -o "$i" == "performance_schema" -o "$i" == "mysql" -o "$i" == "sys" ] 
then
	echo $i ":System Database will not be dumped" >>$MY_LOGFILE
else 
	export SOURCE_DATABASE_NAME=$SOURCE_DATABASE_NAME$i" "
fi
done


echo $(date) : "The databases which will be migrated  are $SOURCE_DATABASE_NAME " >>$MY_LOGFILE
echo "The Following databases will be migrated  are $SOURCE_DATABASE_NAME " 
# Remove dump file if it already exists
[ -e $MY_SOURCEDBSERVER"_backup.sql" ] && rm -f $MY_SOURCEDBSERVER"_backup.sql" 
# Create a dump file of the source db
export MYSQL_PWD=$MY_SOURCEUSERPWD
echo $(date) : "Dumping Databases to file...... " >>$MY_LOGFILE
mysqldump $sslswitch -Fc --routines --log-error=$MY_MYSQLDUMPLOG --host="$MY_SOURCEDBSERVER.mysql.database.azure.com" --user="$MY_SOURCEUSER" --databases $SOURCE_DATABASE_NAME >$MY_SOURCEDBSERVER"_backup.sql" 
# check that filesize of dump file is greater than 0
if ! [ -s $MY_SOURCEDBSERVER"_backup.sql" ]; then
  echo 'Error during mysqldump...' >>$MY_LOGFILE
  echo $(date) : "For Errors refer to $MY_MYSQLDUMPLOG file...... " >>$MY_LOGFILE
  exit 1
fi
echo $(date) : "For more details refer to $MY_MYSQLDUMPLOG file...... " >>$MY_LOGFILE
echo $(date) : "Restoring the databases $SOURCE_DATABASE_NAME...... " >>$MY_LOGFILE
#Restore the dump file to destination
export MYSQL_PWD=$MY_TARGETUSERPWD
mysql $sslswitch --host=$MY_TARGETDBSERVER".mysql.database.azure.com" --port=3306 --user=$MY_TARGETUSER < $MY_SOURCEDBSERVER"_backup.sql" 
##########Please comment this section if you want to cutover and not use source anymore
if [ "$MY_MYSELECTIONROAFTER" = "NO" ]
then 
	echo $(date) : "Making the Source database Read Write" >>$MY_LOGFILE
	echo "Making the Source database Read Write" 
	#SET the source server to Read -Write  

		case $MY_MYSCENARIO in
				"Single-To-Flexible")
				az mysql server configuration set --name read_only --resource-group $MY_SOURCERG  --server $MY_SOURCEDBSERVER --subscription $MY_SOURCESUBSCRIPTION --value OFF >>$MY_LOGFILE
				;;
				"Flexible-To-Flexible")
				az mysql flexible-server parameter set --resource-group $MY_SOURCERG  --server $MY_SOURCEDBSERVER --subscription $MY_SOURCESUBSCRIPTION --name read_only --value OFF >>$MY_LOGFILE
				;;
				"Single-To-Single")
				az mysql server configuration set --name read_only --resource-group $MY_SOURCERG  --server $MY_SOURCEDBSERVER --subscription $MY_SOURCESUBSCRIPTION --value OFF >>$MY_LOGFILE
				;;
				"Flexible-To-Single")
				az mysql flexible-server parameter set --resource-group $MY_SOURCERG  --server $MY_SOURCEDBSERVER --subscription $MY_SOURCESUBSCRIPTION --name read_only --value OFF >>$MY_LOGFILE
				;;
		esac
fi

######################End-Section############################################

#Only values modified from the default will be changed
#get the List of Parameter and the value which is changed from default
if [ "$MY_MYSELECTIONSERVERPARAMETER" = "NO" ]
then 
	echo $(date) : "Migrating Server Parameter (Values Changed by the User)....." >>$MY_LOGFILE
	echo "Migrating Server Parameter....."
	echo $(date) : "Get list of Parameters which does not have Default Value....." >>$MY_LOGFILE
	echo "Get list of Parameters which does not have Default Value....."
	case $MY_MYSCENARIO in
			"Single-To-Flexible")
			parameters=$(az mysql server configuration list --resource-group $MY_SOURCERG --server-name $MY_SOURCEDBSERVER --subscription $MY_SOURCESUBSCRIPTION --output json)
			;;
			"Flexible-To-Flexible")
			parameters=$(az mysql flexible-server configuration list --resource-group $MY_SOURCERG --server-name $MY_SOURCEDBSERVER --subscription $MY_SOURCESUBSCRIPTION --output json)
			;;
			"Single-To-Single")
			parameters=$(az mysql server configuration list --resource-group $MY_SOURCERG --server-name $MY_SOURCEDBSERVER --subscription $MY_SOURCESUBSCRIPTION --output json)
			;;
			"Flexible-To-Single")
			parameters=$(az mysql flexible-server configuration list --resource-group $MY_SOURCERG --server-name $MY_SOURCEDBSERVER --subscription $MY_SOURCESUBSCRIPTION --output json)
			;;
	esac
	changedparameters=$(jq -c '.[] | select(.defaultValue!=.value) | {name: .name, value: .value}' <<<$parameters)

	for i in $changedparameters;do
		pname=$(jq -r '.name' <<< $i)
		pvalue=$(jq -r '.value' <<< $i)
		if ! [ "$pname" == "server_id" -o "$pname" == "read_only" ] 
		then
			echo $(date) : "Changing the Server Parameter --$pname-- to --Value-- $pvalue" >>$MY_LOGFILE
			echo "Changing the Server Parameter --$pname-- to --Value-- $pvalue"
			case $MY_MYSCENARIO in
					"Single-To-Flexible")
					az mysql flexible-server parameter set --resource-group $MY_TARGETRG --server-name $MY_TARGETDBSERVER --subscription $MY_TARGETSUBSCRIPTION --name $pname --value $pvalue >>$MY_LOGFILE
					;;
					"Flexible-To-Flexible")
					az mysql flexible-server parameter set --resource-group $MY_TARGETRG --server-name $MY_TARGETDBSERVER --subscription $MY_TARGETSUBSCRIPTION --name $pname --value $pvalue >>$MY_LOGFILE
					;;
					"Single-To-Single")
					az mysql server configuration set --name $pname --resource-group $MY_TARGETRG --server-name $MY_TARGETDBSERVER --subscription $MY_TARGETSUBSCRIPTION --value $pvalue >>$MY_LOGFILE
					;;
					"Flexible-To-Single")
					az mysql server configuration set --name $pname --resource-group $MY_TARGETRG --server-name $MY_TARGETDBSERVER --subscription $MY_TARGETSUBSCRIPTION --value $pvalue >>$MY_LOGFILE
					;;
			esac
		fi
	done
fi

###########################Database Validation####################################################
 if [ "$MY_MYSELECTIONVALIDATE" = "NO" ]
then 
	echo $(date) : "Validating the Data Migration....." >>$MY_LOGFILE
	echo "Validating the Database Migration....."
	echo $(date) : "Check $MY_MYSQLVALIDATIONREPORT for Database Migration Validation....." >>$MY_LOGFILE
	echo "Check $MY_MYSQLVALIDATIONREPORT for Databse Migration Validation....."
	 echo -e "\e[1;32m Starting Database Migration Validation..... \e[0m "
	echo $(date) : "Getting List of User databases migrated" >>$MY_LOGFILE
	echo "Getting List of User databases migrated" 
		case $MY_MYSCENARIO in
				"Single-To-Flexible")
				mydbs=$(az mysql db list --resource-group $MY_SOURCERG  --server $MY_SOURCEDBSERVER --subscription $MY_SOURCESUBSCRIPTION --query [].name --output tsv)
				;;
				"Flexible-To-Flexible")
				mydbs=$(az mysql flexible-server db list --resource-group $MY_SOURCERG  --server-name $MY_SOURCEDBSERVER --subscription $MY_SOURCESUBSCRIPTION --query [].name --output tsv)
				;;
				"Single-To-Single")
				mydbs=$(az mysql db list --resource-group $MY_SOURCERG  --server $MY_SOURCEDBSERVER --subscription $MY_SOURCESUBSCRIPTION --query [].name --output tsv)
				;;
				"Flexible-To-Single")
				mydbs=$(az mysql flexible-server db list --resource-group $MY_SOURCERG  --server-name $MY_SOURCEDBSERVER --subscription $MY_SOURCESUBSCRIPTION --query [].name --output tsv)
				;;
		esac
	 if ! [ "$MY_MYDBSELECTION" = "ALL" ]
	then 
		export mydbs=$MY_MYDBSELECTION
	fi
	tab=$(echo -e "\x09")
	########Run the below for each migrated database#################

	echo "Validation Report $(date) " >$MY_MYSQLVALIDATIONREPORT
	arrcount=0
	tbldata[$arrcount]="Database Name|Source table Count |Target Table count"
	vtbldata[$arrcount]="Database Name|Source View Count |Target View count"
	trtbldata[$arrcount]="Database Name|Source Trigger Count |Target Trigger count"
	rotbldata[$arrcount]="Database Name|Source routines Count |Target routines count"
	cotbldata[$arrcount]="Database Name|Source constraint Count |Target constraint count"
	arrcount=$arrcount+1
	tbldata[$arrcount]="+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	vtbldata[$arrcount]="+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	trtbldata[$arrcount]="+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	rotbldata[$arrcount]="+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	cotbldata[$arrcount]="+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

	for i in $(echo $mydbs | tr " " "\n")
	do
	if ! [ "$i" == "information_schema" -o "$i" == "performance_schema" -o "$i" == "mysql" -o "$i" == "sys" ]
	then
		db=$i
		arrcount=$arrcount+1
		echo "Validation Report for database $db " >>$MY_MYSQLVALIDATIONREPORT
		# Validating Tables
		echo "Validating the no of tables in Database $db" >>$MY_MYSQLVALIDATIONREPORT
		export MYSQL_PWD=$MY_SOURCEUSERPWD
		sdbvalue=$( mysql -N $sslswitch --host="$MY_SOURCEDBSERVER.mysql.database.azure.com" --user="$MY_SOURCEUSER"  -e "SELECT Count(*)  FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '$db';  ")
		export MYSQL_PWD=$MY_TARGETUSERPWD
		tdbvalue=$( mysql -N $sslswitch --host="$MY_TARGETDBSERVER.mysql.database.azure.com" --user="$MY_TARGETUSER"  -e "SELECT Count(*)  FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '$db';  ")
		echo "No of Tables in $MY_SOURCEDBSERVER for $db is $sdbvalue " >>$MY_MYSQLVALIDATIONREPORT
		tbldata[$arrcount]="$db${tab}|$sdbvalue${tab}|$tdbvalue${tab}"
		echo "No of Tables in $MY_TARGETDBSERVER for $db is $tdbvalue " >>$MY_MYSQLVALIDATIONREPORT
		if [ "$sdbvalue" == "$tdbvalue" ]
		then
		echo "----------Table Count Validated successfully for $db----------" >>$MY_MYSQLVALIDATIONREPORT
		else
		echo "Error: Migration Issue detected on tables in $db please validate running SELECT Count(*)  FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '$db'" >>$MY_MYSQLVALIDATIONREPORT
		fi
		# Validating Views
		echo "Validating the no of Views in Database $db" >>$MY_MYSQLVALIDATIONREPORT
		export MYSQL_PWD=$MY_SOURCEUSERPWD
		sdbvalue=$( mysql -N $sslswitch --host="$MY_SOURCEDBSERVER.mysql.database.azure.com" --user="$MY_SOURCEUSER"  -e "SELECT Count(*)  FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_SCHEMA = '$db';  ")
		export MYSQL_PWD=$MY_TARGETUSERPWD
		tdbvalue=$( mysql -N $sslswitch --host="$MY_TARGETDBSERVER.mysql.database.azure.com" --user="$MY_TARGETUSER"  -e "SELECT Count(*)  FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_SCHEMA = '$db';  ")
		echo "No of Views in $MY_SOURCEDBSERVER for $db is $sdbvalue " >>$MY_MYSQLVALIDATIONREPORT
		vtbldata[$arrcount]="$db${tab}|$sdbvalue${tab}|$tdbvalue${tab}"
		echo "No of Views in $MY_TARGETDBSERVER for $db is $tdbvalue " >>$MY_MYSQLVALIDATIONREPORT
		if [ "$sdbvalue" == "$tdbvalue" ]
		then
		echo "----------View Count Validated successfully  for $db-----------" >>$MY_MYSQLVALIDATIONREPORT
		else
		echo "Error: Migration Issue detected on Views in $db please validate running SELECT Count(*)  FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_SCHEMA = '$db';" >>$MY_MYSQLVALIDATIONREPORT
		fi
		# Validating Triggers
		echo "Validating the no of Triggers in Database $db" >>$MY_MYSQLVALIDATIONREPORT
		export MYSQL_PWD=$MY_SOURCEUSERPWD
		sdbvalue=$( mysql -N $sslswitch --host="$MY_SOURCEDBSERVER.mysql.database.azure.com" --user="$MY_SOURCEUSER"  -e "SELECT Count(*)  FROM INFORMATION_SCHEMA.TRIGGERS WHERE TRIGGER_SCHEMA = '$db';  ")
		export MYSQL_PWD=$MY_TARGETUSERPWD
		tdbvalue=$( mysql -N $sslswitch --host="$MY_TARGETDBSERVER.mysql.database.azure.com" --user="$MY_TARGETUSER"  -e "SELECT Count(*)  FROM INFORMATION_SCHEMA.TRIGGERS WHERE TRIGGER_SCHEMA = '$db';  ")
		echo "No of Triggers in $MY_SOURCEDBSERVER for $db is $sdbvalue " >>$MY_MYSQLVALIDATIONREPORT
		trtbldata[$arrcount]="$db${tab}|$sdbvalue${tab}|$tdbvalue${tab}"
		echo "No of Triggers in $MY_TARGETDBSERVER for $db is $tdbvalue " >>$MY_MYSQLVALIDATIONREPORT
		if [ "$sdbvalue" == "$tdbvalue" ]
		then
		echo "-------Trigger Count Validated successfully  for $db----------" >>$MY_MYSQLVALIDATIONREPORT
		else
		echo "Error: Migration Issue detected on Triggers in $db please validate running SELECT Count(*)  FROM INFORMATION_SCHEMA.TRIGGERS WHERE TRIGGER_SCHEMA = '$db';" >>$MY_MYSQLVALIDATIONREPORT
		fi
		# Validating Routines -- Functions and Procedures 
		echo "Validating the no of Routines -- Functions and Procedures in Database $db" >>$MY_MYSQLVALIDATIONREPORT
		export MYSQL_PWD=$MY_SOURCEUSERPWD
		sdbvalue=$( mysql -N $sslswitch --host="$MY_SOURCEDBSERVER.mysql.database.azure.com" --user="$MY_SOURCEUSER"  -e "SELECT Count(*)  FROM INFORMATION_SCHEMA.routines WHERE routine_SCHEMA = '$db';  ")
		export MYSQL_PWD=$MY_TARGETUSERPWD
		tdbvalue=$( mysql -N $sslswitch --host="$MY_TARGETDBSERVER.mysql.database.azure.com" --user="$MY_TARGETUSER"  -e "SELECT Count(*)  FROM INFORMATION_SCHEMA.routines WHERE routine_SCHEMA = '$db';  ")
		echo "No of Routines in $MY_SOURCEDBSERVER for $db is $sdbvalue " >>$MY_MYSQLVALIDATIONREPORT
		rotbldata[$arrcount]="$db${tab}|$sdbvalue${tab}|$tdbvalue${tab}"
		echo "No of Routines in $MY_TARGETDBSERVER for $db is $tdbvalue " >>$MY_MYSQLVALIDATIONREPORT
		if [ "$sdbvalue" == "$tdbvalue" ]
		then
		echo "-------Routines Count Validated successfully  for $db-------" >>$MY_MYSQLVALIDATIONREPORT
		else
		echo "Error: Migration Issue detected on routines in $db please validate running SELECT Count(*)  FROM INFORMATION_SCHEMA.routines WHERE routine_SCHEMA = '$db';" >>$MY_MYSQLVALIDATIONREPORT
		fi
		#Validating Constraints 
			echo "Validating the no of Constraints in Database $db" >>$MY_MYSQLVALIDATIONREPORT
			export MYSQL_PWD=$MY_SOURCEUSERPWD
			sdbvalue=$( mysql -N $sslswitch --host="$MY_SOURCEDBSERVER.mysql.database.azure.com" --user="$MY_SOURCEUSER"  -e "SELECT Count(*)  FROM INFORMATION_SCHEMA.table_constraints WHERE constraint_schema = '$db';  ")
			export MYSQL_PWD=$MY_TARGETUSERPWD
			tdbvalue=$( mysql -N $sslswitch --host="$MY_TARGETDBSERVER.mysql.database.azure.com" --user="$MY_TARGETUSER"  -e "SELECT Count(*)  FROM INFORMATION_SCHEMA.table_constraints WHERE constraint_schema = '$db';  ")
			echo "No of Constraints in $MY_SOURCEDBSERVER for $db is $sdbvalue " >>$MY_MYSQLVALIDATIONREPORT
			cotbldata[$arrcount]="$db${tab}|$sdbvalue${tab}|$tdbvalue${tab}"
			echo "No of Constraints in $MY_TARGETDBSERVER for $db is $tdbvalue " >>$MY_MYSQLVALIDATIONREPORT
			if [ "$sdbvalue" == "$tdbvalue" ]
			then
			echo "--------Constraints Count Validated successfully  for $db--------" >>$MY_MYSQLVALIDATIONREPORT
			else
			echo "Error:Migration Issue detected on Constraints in $db please validate running SELECT Count(*)  FROM INFORMATION_SCHEMA.table_constraints WHERE constraint_schema = '$db';" >>$MY_MYSQLVALIDATIONREPORT
			fi
		#validating Rows per table for each database 
			errflg="TRUE"
			echo "Validating the no of total number of rows in tables in Database $db" >>$MY_MYSQLVALIDATIONREPORT

			export MYSQL_PWD=$MY_SOURCEUSERPWD
			mysql -N $sslswitch --host="$MY_SOURCEDBSERVER.mysql.database.azure.com" --user="$MY_SOURCEUSER"  -e "SELECT table_name, table_rows FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '$db';"  >$MY_SOURCEDBSERVER"_table.sql"
			export MYSQL_PWD=$MY_TARGETUSERPWD
			mysql -N $sslswitch --host="$MY_TARGETDBSERVER.mysql.database.azure.com" --user="$MY_TARGETUSER"  -e "SELECT table_name, table_rows FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA ='$db';" >$MY_TARGETDBSERVER"_table.sql"
			if cmp -s $MY_SOURCEDBSERVER"_table.sql" $MY_TARGETDBSERVER"_table.sql"; then
			echo "--------Validated Rows per Database table successfully  for $db--------" >>$MY_MYSQLVALIDATIONREPORT
			else
			echo "Error:Migration Issue detected on Table in $db please verify the rows running command : SELECT table_name, table_rows FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA ='$db';" >>$MY_MYSQLVALIDATIONREPORT
			errflg="FALSE"
			fi
		rm $MY_SOURCEDBSERVER"_table.sql"
		rm $MY_TARGETDBSERVER"_table.sql"
		echo "******************************************************************************************">>$MY_MYSQLVALIDATIONREPORT
	fi
	done

	echo "The Summary Report for the validation">>$MY_MYSQLVALIDATIONREPORT
	echo "***************************************************************">>$MY_MYSQLVALIDATIONREPORT
	if [ "$errflg" == "TRUE" ] 
	then 
	echo "No of Rows per table for all database is similar">>$MY_MYSQLVALIDATIONREPORT
	else
	echo "No of Rows per table for all database is different : run "cat $MY_MYSQLVALIDATIONREPORT | grep "Error"" for more details">>$MY_MYSQLVALIDATIONREPORT
	fi
	echo "Summary of Count of table validation">>$MY_MYSQLVALIDATIONREPORT
	echo "***************************************************************">>$MY_MYSQLVALIDATIONREPORT
	for data in "${tbldata[@]}"
	do
	  echo "$data" >>$MY_MYSQLVALIDATIONREPORT
	done
	echo "Summary of Count of View validation">>$MY_MYSQLVALIDATIONREPORT
	echo "***************************************************************">>$MY_MYSQLVALIDATIONREPORT
	for data in "${vtbldata[@]}"
	do
	  echo "$data" >>$MY_MYSQLVALIDATIONREPORT
	done
	echo "Summary of Count of Triggers validation">>$MY_MYSQLVALIDATIONREPORT
	echo "***************************************************************">>$MY_MYSQLVALIDATIONREPORT
	for data in "${trtbldata[@]}"
	do
	  echo "$data" >>$MY_MYSQLVALIDATIONREPORT
	done
	echo "Summary of Count of Routines validation">>$MY_MYSQLVALIDATIONREPORT
	echo "***************************************************************" >>$MY_MYSQLVALIDATIONREPORT
	for data in "${rotbldata[@]}"
	do
	  echo "$data" >>$MY_MYSQLVALIDATIONREPORT
	done
	echo "Summary of Count of Constraints validation">>$MY_MYSQLVALIDATIONREPORT
	echo "***************************************************************" >>$MY_MYSQLVALIDATIONREPORT
	for data in "${cotbldata[@]}"
	do
	  echo "$data" >>$MY_MYSQLVALIDATIONREPORT
	done
	 echo -e "\e[1;32m Check $MY_MYSQLVALIDATIONREPORT for Database Migration Validation..... \e[0m "
fi
###############################################################################
	


#################################################################################################
echo $(date) : "Migration Completed successfully.....See $MY_LOGFILE, $MY_MYSQLDUMPLOG for more details" 
echo $(date) : "Migration Completed successfully....." >>$MY_LOGFILE

#Cleanup of files comment these lines if you would like to verify the migration files. 
rm $MY_SOURCEDBSERVER"_usergrant.sql"
rm $MY_SOURCEDBSERVER"_user.sql"
rm $MY_SOURCEDBSERVER"_backup.sql"

##############################################################################################
#############################################END###############################################
