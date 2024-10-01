#!/bin/bash
#
# PURPOSE
# Migrate Azure Database for MySQL Flexible Server from VNET Integrated to PrivateLink
# 
# DESCRIPTION
# Move from private access (virtual network integrated) to PrivateLink
# https://learn.microsoft.com/en-us/azure/mysql/flexible-server/how-to-network-from-private-to-public
#
# PREREQUISITES
# Azure CLI (https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
# 
# ARGUMENTS
# --subscription-id -s                [Required] : Subscription ID.
# --resource-group-name -g            [Required] : Name of resource group.
# --server-name -n                    [Required] : Name of the server.
# --private-endpoint-name -r          [Required] : Name for the private endpoint.
# --integrate-private-dns-zone -z     [Optional] : Whether to integrate with a new Private DNS Zone.
#
# USAGE
# bash mysqlVnetToPrivateEndpoint.sh
#         --subscription-id 'ffffffff-ffff-ffff-ffff-ffffffffffff'
#         --resource-group-name 'mysqlRG'
#         --server-name 'mysqlflex'
#         --private-endpoint-name 'mysqlpe'
#         --integrate-private-dns-zone false
#

function usage()
{
    echo ""
    echo "PURPOSE"
    echo "Migrate Azure Database for MySQL Flexible Server from VNET Integrated to PrivateLink"
    echo ""
    echo "DESCRIPTION"
    echo "Move from private access (virtual network integrated) to PrivateLink"
    echo "https://learn.microsoft.com/en-us/azure/mysql/flexible-server/how-to-network-from-private-to-public"
    echo ""
    echo "PREREQUISITES"
    echo "Azure CLI (https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)"
    echo ""
    echo "ARGUMENTS"
    echo " --subscription-id -s                [Required] : Subscription ID."
    echo " --resource-group-name -g            [Required] : Name of resource group."
    echo " --server-name -n                    [Required] : Name of the server."
    echo " --private-endpoint-name -r          [Required] : Name for the private endpoint."
    echo " --integrate-private-dns-zone -z     [Optional] : Whether to integrate with a new Private DNS Zone. Defaults to False"
    echo ""
    echo "USAGE"
    echo "bash mysqlVnetToPrivateEndpoint.sh"
    echo -e "\t--subscription-id 'ffffffff-ffff-ffff-ffff-ffffffffffff'"
    echo -e "\t--resource-group-name 'mysqlRG'"
    echo -e "\t--server-name 'mysqlflex'"
    echo -e "\t--private-endpoint-name 'mysqlpe'"
    echo -e "\t--integrate-private-dns-zone false"
    echo ""
    exit 1
}

PARAMS=""
while (( "$#" )); do
  case "$1" in
    -h| --help)
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
    -r|--private-endpoint-name)
      PRIVATE_ENDPOINT_NAME=$2
      shift 2
      ;;
    -z|--integrate-private-dns-zone)
      INTEGRATE_PRIVATE_DNS_ZONE=$2
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

if [ -z "$PRIVATE_ENDPOINT_NAME" ]; then
    echo "Error: Private Endpoint Name is required"
    usage
fi

if [ -z "$INTEGRATE_PRIVATE_DNS_ZONE" ]; then
    INTEGRATE_PRIVATE_DNS_ZONE=false
else 
    if [ "$INTEGRATE_PRIVATE_DNS_ZONE" != "true" ] && [ "$INTEGRATE_PRIVATE_DNS_ZONE" != "false" ]; then
      echo "Error: --integrate-private-dns-zone must be either true or false"
      usage
    fi
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

# Get VNET and subnet details
echo "Obtaining Vnet and Subnet details for server $SERVER_NAME"
DELEGATED_SUBNET_RESOURCE_ID=$(az mysql flexible-server show --resource-group "$RESOURCE_GROUP_NAME" --name "$SERVER_NAME" --query "network.delegatedSubnetResourceId" --output tsv)

# Ensure server is VNET Integrated
if [ -z "$DELEGATED_SUBNET_RESOURCE_ID" ]; then
    echo "Error: MySQL Flexible Server is not VNET Integrated"
    exit 1
fi

# Extract VNET and Subnet details
VNET_SUB=$(echo $DELEGATED_SUBNET_RESOURCE_ID | cut -d "/" -f 3)
VNET_RG=$(echo $DELEGATED_SUBNET_RESOURCE_ID | cut -d "/" -f 5)
VNET=$(echo $DELEGATED_SUBNET_RESOURCE_ID | cut -d "/" -f 9)
SUBNET=$(echo $DELEGATED_SUBNET_RESOURCE_ID | cut -d "/" -f 11)

echo "VNET Subscription ID : $VNET_SUB"
echo "VNET Resource Group : $VNET_RG"
echo "VNET Name : $VNET"
echo "Subnet Name : $SUBNET"

echo "Detaching VNET $VNET from server $SERVER_NAME"
az mysql flexible-server detach-vnet --resource-group "$RESOURCE_GROUP_NAME"  --name "$SERVER_NAME" --public-network-access Disabled --yes

echo "Removing Delegations on Subnet $DELEGATED_SUBNET_RESOURCE_ID"
az network vnet subnet update --ids "$DELEGATED_SUBNET_RESOURCE_ID" --remove delegations

MYSQL_FLEX_RESOURCE_ID=$(az mysql flexible-server show --resource-group "$RESOURCE_GROUP_NAME" --name "$SERVER_NAME" --query "id" --output tsv)
MYSQL_FLEX_LOCATION=$(az mysql flexible-server show --resource-group "$RESOURCE_GROUP_NAME" --name "$SERVER_NAME" --query "location" --output tsv)

echo "Creating Private Endpoint $PRIVATE_ENDPOINT_NAME using Subnet $DELEGATED_SUBNET_RESOURCE_ID"
az network private-endpoint create \
  --resource-group "$VNET_RG" \
  --vnet-name "$VNET" \
  --subnet "$SUBNET" \
  --private-connection-resource-id "$MYSQL_FLEX_RESOURCE_ID" \
  --group-id mysqlServer \
  --connection-name "$PRIVATE_ENDPOINT_NAME" \
  --name "$PRIVATE_ENDPOINT_NAME" \
  --location "$MYSQL_FLEX_LOCATION"

if [ "$INTEGRATE_PRIVATE_DNS_ZONE" == "true" ]; then
  echo "Creating Private DNS Zone"
  az network private-dns zone create \
      --resource-group "$VNET_RG" \
      --name "privatelink.mysql.database.azure.com"

  echo "Linking Private DNS Zone with VNET $VNET"
  az network private-dns link vnet create \
      --resource-group "$VNET_RG" \
      --zone-name "privatelink.mysql.database.azure.com" \
      --name "${VNET}Link" \
      --virtual-network "$VNET" \
      --registration-enabled false

  echo "Creating Private DNS Zone Group"
  az network private-endpoint dns-zone-group create \
    --resource-group "$VNET_RG" \
    --endpoint-name "$PRIVATE_ENDPOINT_NAME" \
    --name "${PRIVATE_ENDPOINT_NAME}ZoneGroup" \
    --private-dns-zone "privatelink.mysql.database.azure.com" \
    --zone-name mysqlServer
fi   

# Verify Private Endpoints
echo "Migration Successful !!"
echo "Check the private endpoints here : https://portal.azure.com/#resource/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.DBforMySQL/flexibleServers/$SERVER_NAME/networking"