#!/bin/bash
#
# PURPOSE
# Migrate Azure Database for MySQL Flexible Server from VNET Integrated to Public Access
# 
# DESCRIPTION
# Move from private access (virtual network integrated) to public access
# https://learn.microsoft.com/en-us/azure/mysql/flexible-server/how-to-network-from-private-to-public
#
# PREREQUISITES
# Azure CLI (https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
# 
# ARGUMENTS
# --subscription-id -s     [Required] : Subscription ID.
# --resource-group-name -g [Required] : Name of resource group.
# --server-name -n         [Required] : Name of the server.
# --rule-name -r           [Required] : The name of the firewall rule. The firewall rule name can
#                                       only contain 0-9, a-z, A-Z, '-' and '_'. Additionally, the name
#                                       of the firewall rule must be at least 1 character and no more
#                                       than 80 characters in length.
# --start-ip-address -a    [Required] : The start IP address of the firewall rule. Must be IPv4 format.
#                                       Use value '0.0.0.0' to represent all Azure-internal IP addresses.
# --end-ip-address -b      [Required] : The end IP address of the firewall rule. Must be IPv4 format.
#                                       Use value '0.0.0.0' to represent all Azure-internal IP addresses.
#
# USAGE
# bash mysqlVnetToPublic.sh
#         --subscription-id 'ffffffff-ffff-ffff-ffff-ffffffffffff'
#         --resource-group-name 'mysqlRG'
#         --server-name 'mysqlflex'
#         --firewall-rule-name 'allowiprange'
#         --start-ip-address 107.46.14.0
#         --end-ip-address 107.46.14.221
#

function usage()
{
    echo ""
    echo "PURPOSE"
    echo "Migrate Azure Database for MySQL Flexible Server from VNET Integrated to Public Access"
    echo ""
    echo "DESCRIPTION"
    echo "Move from private access (virtual network integrated) to public access"
    echo "https://learn.microsoft.com/en-us/azure/mysql/flexible-server/how-to-network-from-private-to-public"
    echo ""
    echo "PREREQUISITES"
    echo "Azure CLI (https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)"
    echo ""
    echo "ARGUMENTS"
    echo " --subscription-id -s     [Required] : Subscription ID."
    echo " --resource-group-name -g [Required] : Name of resource group."
    echo " --server-name -n         [Required] : Name of the server."
    echo " --rule-name -r           [Required] : The name of the firewall rule. The firewall rule name can"
    echo "                                       only contain 0-9, a-z, A-Z, '-' and '_'. Additionally, the name"
    echo "                                       of the firewall rule must be at least 1 character and no more"
    echo "                                       than 80 characters in length."
    echo " --start-ip-address -a    [Required] : The start IP address of the firewall rule. Must be IPv4 format."
    echo "                                       Use value '0.0.0.0' to represent all Azure-internal IP addresses."
    echo " --end-ip-address -b      [Required] : The end IP address of the firewall rule. Must be IPv4 format."
    echo "                                       Use value '0.0.0.0' to represent all Azure-internal IP addresses."
    echo ""
    echo "USAGE"
    echo "bash mysqlVnetToPublic.sh"
    echo -e "\t--subscription-id 'ffffffff-ffff-ffff-ffff-ffffffffffff'"
    echo -e "\t--resource-group-name 'mysqlRG'"
    echo -e "\t--server-name 'mysqlflex'"
    echo -e "\t--firewall-rule-name 'allowiprange'"
    echo -e "\t--start-ip-address 107.46.14.0"
    echo -e "\t--end-ip-address 107.46.14.221"
    echo ""
    exit 1
}

PARAMS=""
while (( "$#" )); do
  case "$1" in
    -h | --help)
      usage
      exit
      ;;
    -s|--subscription-id)
      SUBSCRIPTION_ID=$2
      shift 2
      ;;
    -g|--resource-group-name)
      RESOURCE_GROUP_NAME=$2
      shift 2
      ;;
    -n|--server-name)
      SERVER_NAME=$2
      shift 2
      ;;
    -r|--firewall-rule-name)
      FIREWALL_RULE_NAME=$2
      shift 2
      ;;
    -a|--start-ip-address)
      START_IP_ADDRESS=$2
      shift 2
      ;;
    -b|--end-ip-address)
      END_IP_ADDRESS=$2
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

# Ensure required parameters are provided
if [ -z "$SUBSCRIPTION_ID" ]; then
    echo "Error: Subscription ID is required"
    usage
fi

if [ -z "$RESOURCE_GROUP_NAME" ]; then
    echo "Error: Resource Group Name is required"
    usage
fi

if [ -z "$SERVER_NAME" ]; then
    echo "Error: Server Name is required"
    usage
fi

if [ -z "$FIREWALL_RULE_NAME" ]; then
    echo "Error: Firewall Rule Name is required"
    usage
fi

if [ -z "$START_IP_ADDRESS" ]; then
    echo "Error: Start IP Address is required"
    usage
fi

if [ -z "$END_IP_ADDRESS" ]; then
    echo "Error: End IP Address is required"
    usage
fi

# Prerequisites - Install Azure CLI package
if ! [ -x "$(command -v az)" ]; then
  echo 'Error: azure cli is not installed. Please install from https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest' >&2
  exit 1
fi

# Check if the subscription exists
if ! az account list --query "[?id=='$SUBSCRIPTION_ID' || name=='$SUBSCRIPTION_ID'].id" -o tsv | grep -q .; then
    echo "Subscription '$SUBSCRIPTION_ID' does not exist."
    exit 1
fi

# Set subscription
az account set --subscription "$SUBSCRIPTION_ID"

# Check if the resource group exists
if ! az group show --name "$RESOURCE_GROUP_NAME" > /dev/null 2>&1; then
    echo "Resource group '$RESOURCE_GROUP_NAME' does not exist."
    exit 1 
fi

# Check if the MySQL Flexible server exists
if ! az mysql flexible-server show --resource-group "$RESOURCE_GROUP_NAME" --name "$SERVER_NAME" > /dev/null 2>&1; then
    echo "MySQL Flexible Server '$SERVER_NAME' does not exist in resource group '$RESOURCE_GROUP_NAME'."
    exit 1
fi

# Ensure server is VNET Integrated
DELEGATED_SUBNET_RESOURCE_ID=$(az mysql flexible-server show --resource-group "$RESOURCE_GROUP_NAME" --name "$SERVER_NAME" --query "network.delegatedSubnetResourceId" --output tsv)
if [ -z "$DELEGATED_SUBNET_RESOURCE_ID" ]; then
    echo "Error: MySQL Flexible Server is not VNET Integrated"
    exit 1
fi

echo "Detaching VNET from server $SERVER_NAME"
az mysql flexible-server detach-vnet --resource-group "$RESOURCE_GROUP_NAME"  --name "$SERVER_NAME" --public-network-access Enabled --yes

echo "Creating Firewall Rule on server $SERVER_NAME"
az mysql flexible-server firewall-rule create \
  --resource-group "$RESOURCE_GROUP_NAME"  \
  --name "$SERVER_NAME" \
  --rule-name "$FIREWALL_RULE_NAME" \
  --start-ip-address "$START_IP_ADDRESS" \
  --end-ip-address "$END_IP_ADDRESS"

# Verify Firewall Rules
echo "Migration Successful !!"
echo "Check the firewall rules here : https://portal.azure.com/#resource/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.DBforMySQL/flexibleServers/$SERVER_NAME/networking"