#!/bin/bash
#
# PURPOSE
# Migrate Azure Database for MySQL Server from Basic Pricing Tier to General Purpose/Memory Optimized Pricing Tier
# 
# DESCRIPTION
# Pricing tiers in Azure Database for MySQL - Single Server
# https://docs.microsoft.com/en-us/azure/mysql/concepts-pricing-tiers
# 
# Currently modifying pricing tier (to and from Basic) is not yet supported. 
# This script helps in migrating an existing database from Basic Pricing Tier to 
# General Purpose/Memory Optimized Pricing Tier. 
# This script uses mysqldump to extract a MySQL database into a dump file
# and mysql to restore the MySQL database from an archive file created by mysqldump.
#
# Migrate your MySQL database using dump and restore
# https://docs.microsoft.com/en-us/azure/mysql/howto-migrate-using-dump-and-restore
#
# PREREQUISITES
# Azure CLI (https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
# mysql-client tools - mysqldump and mysql (https://dev.mysql.com/downloads/mysql/)
# 
# NOTE
# Target server and database are created in this script.
# Please modify the script to specify different options for creation
# https://docs.microsoft.com/en-us/cli/azure/mysql/server?view=azure-cli-latest
# 
# USAGE
# bash mysqlmigrate.sh
#         --source-subscription-id 'ffffffff-ffff-ffff-ffff-ffffffffffff'
#         --source-resource-group-name 'sourceRG'
#         --source-server-name 'sourcemysql'
#         --source-username 'sourceuser'
#         --source-password 'P@ssw0rd1'
#         --source-database-name 'sourcedb'
#         --target-subscription-id 'ffffffff-ffff-ffff-ffff-ffffffffffff'
#         --target-resource-group-name 'targetRG'
#         --target-region 'eastus'
#         --target-server-name 'targetmysql'
#         --target-username 'targetuser'
#         --target-password 'P@ssw0rd2'
#         --target-database-name 'targetdb'
#         --target-sku 'GP_Gen5_2'
#

function usage()
{
    echo ""
    echo "PURPOSE"
    echo "Migrate Azure Database for MySQL Server from Basic Pricing Tier to General Purpose/Memory Optimized Pricing Tier"
    echo ""
    echo "DESCRIPTION"
    echo "Pricing tiers in Azure Database for MySQL - Single Server"
    echo "https://docs.microsoft.com/en-us/azure/mysql/concepts-pricing-tiers"
    echo ""
    echo "Currently modifying pricing tier (to and from Basic) is not yet supported."
    echo "This script helps in migrating an existing database from Basic Pricing Tier to"
    echo "General Purpose/Memory Optimized Pricing Tier."
    echo "This script uses mysqldump to extract a MySQL database into a dump file"
    echo "and mysql to restore the MySQL database from an archive file created by mysqldump."
    echo ""
    echo "Migrate your MySQL database using dump and restore"
    echo "https://docs.microsoft.com/en-us/azure/mysql/howto-migrate-using-dump-and-restore"
    echo ""
    echo "PREREQUISITES"
    echo "Azure CLI (https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)"
    echo "mysql-client tools - mysqldump and mysql (https://dev.mysql.com/downloads/mysql/)"
    echo ""
    echo "NOTE"
    echo "Target server and database are created in this script."
    echo "Please modify the script to specify different options for server creation"
    echo "https://docs.microsoft.com/en-us/cli/azure/mysql/server?view=azure-cli-latest"
    echo ""
    echo "USAGE"
    echo "bash mysqlmigrate.sh"
    echo -e "\t--source-subscription-id 'ffffffff-ffff-ffff-ffff-ffffffffffff'"
    echo -e "\t--source-resource-group-name 'sourceRG'"
    echo -e "\t--source-server-name 'sourcemysql'"
    echo -e "\t--source-username 'sourceuser'"
    echo -e "\t--source-password 'P@ssw0rd1'"
    echo -e "\t--source-database-name 'sourcedb'"
    echo -e "\t--target-subscription-id 'ffffffff-ffff-ffff-ffff-ffffffffffff'"
    echo -e "\t--target-resource-group-name 'targetRG'"
    echo -e "\t--target-region 'eastus'"
    echo -e "\t--target-server-name 'targetmysql'"
    echo -e "\t--target-username 'targetuser'"
    echo -e "\t--target-password 'P@ssw0rd2'"
    echo -e "\t--target-database-name 'targetdb'"
    echo -e "\t--target-sku 'GP_Gen5_2'"
    echo ""
}

PARAMS=""
while (( "$#" )); do
  case "$1" in
    -h | --help)
      usage
      exit
      ;;
    -a|--source-subscription-id)
      SOURCE_SUBSCRIPTION_ID=$2
      shift 2
      ;;
    -b|--source-resource-group-name)
      SOURCE_RESOURCE_GROUP_NAME=$2
      shift 2
      ;;
    -c|--source-server-name)
      SOURCE_SERVER_NAME=$2
      shift 2
      ;;
    -d|--source-username)
      SOURCE_USERNAME=$2
      shift 2
      ;;
    -e|--source-password)
      SOURCE_PASSWORD=$2
      shift 2
      ;;
    -f|--source-database-name)
      SOURCE_DATABASE_NAME=$2
      shift 2
      ;;
    -g|--target-subscription-id)
      TARGET_SUBSCRIPTION_ID=$2
      shift 2
      ;;
    -h|--target-resource-group-name)
      TARGET_RESOURCE_GROUP_NAME=$2
      shift 2
      ;;
    -i|--target-region)
      TARGET_REGION=$2
      shift 2
      ;;
    -j|--target-server-name)
      TARGET_SERVER_NAME=$2
      shift 2
      ;;
    -k|--target-username)
      TARGET_USERNAME=$2
      shift 2
      ;;
    -l|--target-password)
      TARGET_PASSWORD=$2
      shift 2
      ;;
    -m|--target-database-name)
      TARGET_DATABASE_NAME=$2
      shift 2
      ;;
    -n|--target-sku)
      TARGET_SKU=$2
      shift 2
      ;;
    --) # end argument parsing
      shift
      break
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done
# set positional arguments in their proper place
eval set -- "$PARAMS"

# Prerequisites - Install Azure CLI and mysql-client package
if ! [ -x "$(command -v az)" ]; then
  echo 'Error: azure cli is not installed. Please install from https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest' >&2
  exit 1
fi

if ! [ -x "$(command -v mysqldump)" ]; then
  echo 'Error: mysqldump command does not exist. Please install from https://dev.mysql.com/downloads/mysql/' >&2
  exit 1
fi

if ! [ -x "$(command -v mysql)" ]; then
  echo 'Error: mysql command does not exist. Please install from https://dev.mysql.com/downloads/mysql/' >&2
  exit 1
fi

# Login to source subscription
az login
az account set --subscription "$SOURCE_SUBSCRIPTION_ID"

# Firewall rule name to allow the current VM
export FIREWALLRULENAME="AllowAllIps$(date +%s)"

# Create firewall rule on the source server to allow connections from current VM
az mysql server firewall-rule create -g "$SOURCE_RESOURCE_GROUP_NAME" -s "$SOURCE_SERVER_NAME" -n "$FIREWALLRULENAME" --start-ip-address "0.0.0.0" --end-ip-address "255.255.255.255"

# Export mysql password to be used by the mysqldump command
export MYSQL_PWD=$SOURCE_PASSWORD

# Remove dump file if it already exists
[ -e "$SOURCE_DATABASE_NAME.sql" ] && rm -f "$SOURCE_DATABASE_NAME.sql"

# Create a dump file of the source db
mysqldump --ssl-mode=REQUIRED -Fc -v --host="$SOURCE_SERVER_NAME.mysql.database.azure.com" --user="$SOURCE_USERNAME@$SOURCE_SERVER_NAME" --databases "$SOURCE_DATABASE_NAME" >"$SOURCE_DATABASE_NAME.sql"

# check that filesize of dump file is greater than 0
if ! [ -s "$SOURCE_DATABASE_NAME.sql" ]; then
  echo 'Error during mysqldump' >&2
  exit 1
fi

# Login to target subscription 
az account set --subscription "$TARGET_SUBSCRIPTION_ID"

# Set target server password
export MYSQL_PWD=$TARGET_PASSWORD

# Create the target server in the specified region
az mysql server create -l "$TARGET_REGION" -g "$TARGET_RESOURCE_GROUP_NAME" -n "$TARGET_SERVER_NAME" -u "$TARGET_USERNAME" -p "$MYSQL_PWD" --sku-name "$TARGET_SKU"

# Create the target database
az mysql db create -g "$TARGET_RESOURCE_GROUP_NAME" -s "$TARGET_SERVER_NAME" -n "$TARGET_DATABASE_NAME"

# Create firewall rule on the target server to allow connections from current VM
az mysql server firewall-rule create -g "$TARGET_RESOURCE_GROUP_NAME" -s "$TARGET_SERVER_NAME" -n "$FIREWALLRULENAME" --start-ip-address "0.0.0.0" --end-ip-address "255.255.255.255"

# Export MYSQL database name to be used by the mysql command
export MYSQL_DATABASE=$TARGET_DATABASE_NAME

# Restore the database using source database dump file
mysql --ssl-mode=REQUIRED -v --host="$TARGET_SERVER_NAME.mysql.database.azure.com" --port=3306 --user="$TARGET_USERNAME@$TARGET_SERVER_NAME" < "$SOURCE_DATABASE_NAME.sql"

# Delete firewall rules and local dump file
az mysql server firewall-rule delete -g "$SOURCE_RESOURCE_GROUP_NAME" -s "$SOURCE_SERVER_NAME" -n "$FIREWALLRULENAME" --yes
az mysql server firewall-rule delete -g "$TARGET_RESOURCE_GROUP_NAME" -s "$TARGET_SERVER_NAME" -n "$FIREWALLRULENAME" --yes
rm -f "$SOURCE_DATABASE_NAME.sql"

# Logout
az logout

# Visit Target Server
echo "Migration Successful !!"
echo "Target Server : https://portal.azure.com/#resource/subscriptions/$TARGET_SUBSCRIPTION_ID/resourceGroups/$TARGET_RESOURCE_GROUP_NAME/providers/Microsoft.DBforMySQL/servers/$TARGET_SERVER_NAME/overview"