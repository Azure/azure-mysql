#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Log file
LOG_FILE="deploy-aks.log"

# Redirect stdout and stderr to log file
exec > >(tee -a $LOG_FILE) 2>&1

waitAndGetExternalIpForService() {
  local service_name=$1
  local namespace=$2
  local external_ip=""
  while [ -z "$external_ip" ]; do
      echo "Waiting for external IP..." >&2
      external_ip=$(sudo kubectl get service $service_name -n $namespace --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
      if [ -z "$external_ip" ]; then
          sleep 10
      fi
  done
  echo $external_ip
}

# Parameters
AZURE_SUBSCRIPTION_ID=$1
AZURE_RESOURCE_GROUP=$2
SERVICE_PRINCIPAL_APP_ID=$3
SERVICE_PRINCIPAL_PASSWORD=$4
TENANT_ID=$5
COMPOSER_USERNAME=$6
COMPOSER_PASSWORD=$7
MY_SQL_SERVER_HOST_NAME=$8
MY_SQL_SERVER_ADMIN_LOGIN=$9
MY_SQL_SERVER_ADMIN_PASSWORD=${10}
AKS_CLUSTER_NAME=${11}
STORAGE_ACCOUNT_ACCESS_NAME=${12}
STORAGE_ACCOUNT_ACCESS_KEY=${13}
MAGENTO_ADMIN_USERNAME=${14}
MAGENTO_ADMIN_PASSWORD=${15}
VIRTUAL_MACHINE_NAME=${16}
EXTERNAL_FQDN=${17}
CDN_PROFILE_NAME=${18}
REDIS_CACHE_SWITCH=${19}
VARNISH_CACHE_SWITCH=${20}
CDN_SWITCH=${21}
TLS_SWITCH=${22}
AKS_SECRET_PROVIDER_CLIENT_ID=${23}
KEYVAULT_NAME=${24}
CERTIFICATE_NAME=${25}
MAGENTO_ADMIN_EMAIL=${26}
MAGENTO_CURRENCY=${27}
MAGENTO_TIMEZONE=${28}

# Printing all parameters
echo "AZURE_SUBSCRIPTION_ID: $AZURE_SUBSCRIPTION_ID"
echo "AZURE_RESOURCE_GROUP: $AZURE_RESOURCE_GROUP"
echo "SERVICE_PRINCIPAL_APP_ID: $SERVICE_PRINCIPAL_APP_ID"
echo "SERVICE_PRINCIPAL_PASSWORD: $SERVICE_PRINCIPAL_PASSWORD"
echo "TENANT_ID: $TENANT_ID"
echo "COMPOSER_USERNAME: $COMPOSER_USERNAME"
echo "COMPOSER_PASSWORD: $COMPOSER_PASSWORD"
echo "MY_SQL_SERVER_HOST_NAME: $MY_SQL_SERVER_HOST_NAME"
echo "MY_SQL_SERVER_ADMIN_LOGIN: $MY_SQL_SERVER_ADMIN_LOGIN"
echo "MY_SQL_SERVER_ADMIN_PASSWORD: $MY_SQL_SERVER_ADMIN_PASSWORD"
echo "AKS_CLUSTER_NAME: $AKS_CLUSTER_NAME"
echo "STORAGE_ACCOUNT_ACCESS_NAME: $STORAGE_ACCOUNT_ACCESS_NAME"
echo "STORAGE_ACCOUNT_ACCESS_KEY: $STORAGE_ACCOUNT_ACCESS_KEY"
echo "MAGENTO_ADMIN_USERNAME: $MAGENTO_ADMIN_USERNAME"
echo "MAGENTO_ADMIN_PASSWORD: $MAGENTO_ADMIN_PASSWORD"
echo "VIRTUAL_MACHINE_NAME: $VIRTUAL_MACHINE_NAME"
echo "EXTERNAL_FQDN: $EXTERNAL_FQDN"
echo "CDN_PROFILE_NAME: $CDN_PROFILE_NAME"
echo "REDIS_CACHE_SWITCH: $REDIS_CACHE_SWITCH"
echo "VARNISH_CACHE_SWITCH: $VARNISH_CACHE_SWITCH"
echo "CDN_SWITCH: $CDN_SWITCH"
echo "TLS_SWITCH: $TLS_SWITCH"
echo "AKS_SECRET_PROVIDER_CLIENT_ID: $AKS_SECRET_PROVIDER_CLIENT_ID"
echo "KEYVAULT_NAME: $KEYVAULT_NAME"
echo "CERTIFICATE_NAME: $CERTIFICATE_NAME"
echo "MAGENTO_ADMIN_EMAIL: $MAGENTO_ADMIN_EMAIL"
echo "MAGENTO_CURRENCY: $MAGENTO_CURRENCY"
echo "MAGENTO_TIMEZONE: $MAGENTO_TIMEZONE"

echo "External FQDN: $EXTERNAL_FQDN"
# Mocking External FQDN (if not provided)
if [ "${EXTERNAL_FQDN}" = "EXTERNAL_FQDN" ]; then
  EXTERNAL_FQDN=''
fi
echo "Final External FQDN: $EXTERNAL_FQDN"

echo "KeyVault Name: $KEYVAULT_NAME"
# Mocking KeyVault Name (if not provided)
if [ "${KEYVAULT_NAME}" = "KEYVAULT_NAME" ]; then
  KEYVAULT_NAME=''
fi
echo "Final KeyVault Name: $KEYVAULT_NAME"

echo "Certificate Name: $CERTIFICATE_NAME"
# Mocking Certificate Name (if not provided)
if [ "${CERTIFICATE_NAME}" = "CERTIFICATE_NAME" ]; then
  CERTIFICATE_NAME=''
fi
echo "Final Certificate Name: $CERTIFICATE_NAME"


# Variables
aks_namespace="magento"

# Install Azure CLI
echo "Installing Azure CLI..."
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install kubectl
echo "Installing kubectl..."
sudo az aks install-cli

# Install Helm
echo "Installing Helm..."
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm

# Login to Azure using Service Principal
echo "Logging into Azure..."
sudo az login --service-principal --username "$SERVICE_PRINCIPAL_APP_ID" --password "$SERVICE_PRINCIPAL_PASSWORD" --tenant "$TENANT_ID"

# Set the Azure subscription
echo "Setting the Azure subscription..."
sudo az account set --subscription "$AZURE_SUBSCRIPTION_ID"

# Get AKS credentials
echo "Getting AKS credentials..."
while [[ $(sudo az aks show -g "$AZURE_RESOURCE_GROUP" -n "$AKS_CLUSTER_NAME" --query "provisioningState" -o tsv) != "Succeeded" ]]; do
    echo "Waiting for AKS cluster "$AKS_CLUSTER_NAME" in resource group "$AZURE_RESOURCE_GROUP" to be provisioned..."
    sleep 10s
done
sudo az aks get-credentials --resource-group "$AZURE_RESOURCE_GROUP" --name "$AKS_CLUSTER_NAME"

# Test sudo kubectl access
echo "Testing sudo kubectl access..."
sudo kubectl get nodes

# Start deploying to ASK Cluster
echo "Deploying to AKS Cluster..."

# Defining deployment file URLs
echo "Deploying YAML configurations..."
file_base_url="https://raw.githubusercontent.com/Azure/azure-mysql/refs/heads/master/Magento2/Kubernetes"

# Create the namespace
echo "Creating namespace..."
curl -s "$file_base_url/namespace.yaml" | sudo kubectl apply -f -

# Applying the secret(s) according to Infra deployment
echo "Applying secrets..."
sudo kubectl create secret generic input-secrets -n $aks_namespace \
  --from-literal=MAGENTO_DATABASE_USER=$MY_SQL_SERVER_ADMIN_LOGIN \
  --from-literal=MAGENTO_DATABASE_PASSWORD=$MY_SQL_SERVER_ADMIN_PASSWORD \
  --from-literal=MAGENTO_ADMIN_USER=$MAGENTO_ADMIN_USERNAME \
  --from-literal=MAGENTO_ADMIN_PASSWORD=$MAGENTO_ADMIN_PASSWORD \
  --from-literal=COMPOSER_USERNAME=$COMPOSER_USERNAME \
  --from-literal=COMPOSER_PASSWORD=$COMPOSER_PASSWORD \
  --from-literal=azurestorageaccountname=$STORAGE_ACCOUNT_ACCESS_NAME \
  --from-literal=azurestorageaccountkey=$STORAGE_ACCOUNT_ACCESS_KEY \
  --dry-run=client -o yaml | sudo kubectl apply -f -

# Add the ingress-nginx repository
echo "Adding ingress-nginx repository..."
sudo helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
sudo helm repo update

# Install nginx-ingress controller
echo "Installing nginx-ingress controller..."
sudo helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace $aks_namespace \
  --set controller.replicaCount=1 \
  --set controller.nodeSelector."kubernetes\.io/os"=linux \
  --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux \
  --set controller.service.externalTrafficPolicy=Local

# Get the external IP of the Ingress Controller
echo "Getting external IP of the Ingress Controller..."
external_ip_service_name="ingress-nginx-controller"
external_ip_address=$(waitAndGetExternalIpForService $external_ip_service_name $aks_namespace)
echo "External IP Address: $external_ip_address"

# Applying the input configmap according to Infra deployment
echo "Applying configmaps..."
magento_base_url=""
magento_base_url_secure=""
cdn_origin=""
if [ -n "$EXTERNAL_FQDN" ]; then
  magento_base_url="http://$EXTERNAL_FQDN:80/"
  magento_base_url_secure="https://$EXTERNAL_FQDN:443/"
  cdn_origin=$EXTERNAL_FQDN
else
  magento_base_url="http://$external_ip_address:80/"
  magento_base_url_secure="https://$external_ip_address:443/"
  cdn_origin=$external_ip_address
fi

echo "Magento Base URL: $magento_base_url"
echo "Magento Base URL Secure: $magento_base_url_secure"
echo "CDN Origin: $cdn_origin"

CDN_STATIC_ENDPOINT_HOST=""
CDN_MEDIA_ENDPOINT_HOST=""
if [ "${CDN_SWITCH}" = "true" ] || [ "${CDN_SWITCH}" = "True" ]; then
  # Create CDN Endpoint for static
  echo "Creating CDN Endpoint for static..."
  sudo az cdn endpoint create \
    --endpoint-name magento1-static \
    --profile-name $CDN_PROFILE_NAME \
    --resource-group $AZURE_RESOURCE_GROUP \
    --origin-host-header $cdn_origin \
    --origin $cdn_origin

  # Create CDN Endpoint rule for static
  echo "Creating CDN Endpoint rule for static..."
  sudo az cdn endpoint rule add \
    --profile-name $CDN_PROFILE_NAME \
    --resource-group $AZURE_RESOURCE_GROUP \
    --name magento1-static \
    --rule-name Global \
    --order 0 \
    --action-name ModifyResponseHeader \
    --header-action Overwrite \
    --header-name Access-Control-Allow-Origin \
    --header-value "*"

  # Get CDN URL for static
  echo "Getting CDN URL for static..."
  CDN_STATIC_ENDPOINT_HOST=$(sudo az cdn endpoint show \
    --endpoint-name magento1-static \
    --profile-name $CDN_PROFILE_NAME \
    --resource-group $AZURE_RESOURCE_GROUP \
    --query "hostName" \
    --output tsv)

  # Create CDN Endpoint for media
  echo "Creating CDN Endpoint for media..."
  sudo az cdn endpoint create \
    --endpoint-name magento1-media \
    --profile-name $CDN_PROFILE_NAME \
    --resource-group $AZURE_RESOURCE_GROUP \
    --origin-host-header $cdn_origin \
    --origin $cdn_origin

  # Create CDN Endpoint rule for media
  echo "Creating CDN Endpoint rule for media..."
  sudo az cdn endpoint rule add \
    --profile-name $CDN_PROFILE_NAME \
    --resource-group $AZURE_RESOURCE_GROUP \
    --name magento1-media \
    --rule-name Global \
    --order 0 \
    --action-name ModifyResponseHeader \
    --header-action Overwrite \
    --header-name Access-Control-Allow-Origin \
    --header-value "*"

  # Get CDN URL for media
  echo "Getting CDN URL for media..."
  CDN_MEDIA_ENDPOINT_HOST=$(sudo az cdn endpoint show \
    --endpoint-name magento1-media \
    --profile-name $CDN_PROFILE_NAME \
    --resource-group $AZURE_RESOURCE_GROUP \
    --query "hostName" \
    --output tsv)
else
  CDN_STATIC_ENDPOINT_HOST=$cdn_origin
  CDN_MEDIA_ENDPOINT_HOST=$cdn_origin
fi
echo "CDN Static Endpoint Host: $CDN_STATIC_ENDPOINT_HOST"
echo "CDN Media Endpoint Host: $CDN_MEDIA_ENDPOINT_HOST"


CDN_STATIC_URL="http://$CDN_STATIC_ENDPOINT_HOST/static/"
CDN_MEDIA_URL="http://$CDN_MEDIA_ENDPOINT_HOST/media/"

# Using HTTP for CDN URLs if TLS is not enabled because of self-signed certificate error at CDN
if [ "${TLS_SWITCH}" = "true" ] || [ "${TLS_SWITCH}" = "True" ]; then
  CDN_STATIC_URL_SECURE="https://$CDN_STATIC_ENDPOINT_HOST/static/"
  CDN_MEDIA_URL_SECURE="https://$CDN_MEDIA_ENDPOINT_HOST/media/"
else
  CDN_STATIC_URL_SECURE="http://$CDN_STATIC_ENDPOINT_HOST/static/"
  CDN_MEDIA_URL_SECURE="http://$CDN_MEDIA_ENDPOINT_HOST/media/"
fi

echo "CDN Static URL: $CDN_STATIC_URL"
echo "CDN Media URL: $CDN_MEDIA_URL"
echo "CDN Static URL Secure: $CDN_STATIC_URL_SECURE"
echo "CDN Media URL Secure: $CDN_MEDIA_URL_SECURE"

# Apply Input Configmap
echo "Applying Input Configmap..."
sudo kubectl create configmap input-config -n $aks_namespace \
  --from-literal=MAGENTO_BASE_URL=$magento_base_url \
  --from-literal=MAGENTO_BASE_URL_SECURE=$magento_base_url_secure \
  --from-literal=MAGENTO_ADMIN_EMAIL=$MAGENTO_ADMIN_EMAIL \
  --from-literal=MAGENTO_CURRENCY=$MAGENTO_CURRENCY \
  --from-literal=MAGENTO_TIMEZONE=$MAGENTO_TIMEZONE \
  --from-literal=DATABASE_HOST=$MY_SQL_SERVER_HOST_NAME \
  --from-literal=MAGENTO_BASE_URL_STATIC=$CDN_STATIC_URL \
  --from-literal=MAGENTO_BASE_URL_MEDIA=$CDN_MEDIA_URL \
  --from-literal=MAGENTO_BASE_URL_STATIC_SECURE=$CDN_STATIC_URL_SECURE \
  --from-literal=MAGENTO_BASE_URL_MEDIA_SECURE=$CDN_MEDIA_URL_SECURE \
  --from-literal=REDIS_CACHE_SWITCH=$REDIS_CACHE_SWITCH \
  --from-literal=VARNISH_CACHE_SWITCH=$VARNISH_CACHE_SWITCH \
  --from-literal=CDN_SWITCH=$CDN_SWITCH \
  --dry-run=client -o yaml | sudo kubectl apply -f -

# Apply Storage Class
echo "Applying Storage Class..."
curl -s "$file_base_url/azurefile/sc.yaml?$sas_token" | sudo kubectl apply -n $aks_namespace -f -


# Deploy Elasticsearch
# Apply Elasticsearch PV & PVC
echo "Applying Elasticsearch PV & PVC..."
curl -s "$file_base_url/elasticsearch/pv.yaml?$sas_token" | sudo kubectl apply -n $aks_namespace -f -
curl -s "$file_base_url/elasticsearch/pvc.yaml?$sas_token" | sudo kubectl apply -n $aks_namespace -f -
# Apply Elasticserach Service
echo "Applying Elasticsearch service..."
curl -s "$file_base_url/elasticsearch/services.yaml?$sas_token" | sudo kubectl apply -n $aks_namespace -f -
# Apply Elasticsearch StatefulSet
echo "Applying Elasticsearch StatefulSet..."
curl -s "$file_base_url/elasticsearch/statefulset.yaml?$sas_token" | sudo kubectl apply -n $aks_namespace -f -

# Deploy Redis (if required)
if [ "${REDIS_CACHE_SWITCH}" = "true" ] || [ "${REDIS_CACHE_SWITCH}" = "True" ]; then
  # Apply Redis Service
  echo "Applying Redis Service..."
  curl -s "$file_base_url/redis/services.yaml?$sas_token" | sudo kubectl apply -n $aks_namespace -f -
  # Apply Redis StatefulSet
  echo "Applying Redis StatefulSet..."
  curl -s "$file_base_url/redis/statefulset.yaml?$sas_token" | sudo kubectl apply -n $aks_namespace -f -
fi

# Deploy Magento
# Apply Magento Configmap
echo "Applying Magento Configmap..."
curl -s "$file_base_url/magento/configmap.yaml?$sas_token" | sudo kubectl apply -n $aks_namespace -f -
# Apply Magento PV & PVC
echo "Applying Magento PV & PVC..."
curl -s "$file_base_url/magento/pv.yaml?$sas_token" | sudo kubectl apply -n $aks_namespace -f -
curl -s "$file_base_url/magento/pvc.yaml?$sas_token" | sudo kubectl apply -n $aks_namespace -f -
# Apply Magento Services
echo "Applying Magento Services..."
curl -s "$file_base_url/magento/services.yaml?$sas_token" | sudo kubectl apply -n $aks_namespace -f -
# Apply Magento Job Deployment
echo "Applying Magento job Deployment..."
curl -s "$file_base_url/magento/job.yaml?$sas_token" | sudo kubectl apply -n $aks_namespace -f -
# Wait for the job to complete (timeout 30 minutes)
echo "Waiting for the job to complete..."
sudo kubectl wait --for=condition=complete --timeout=1800s job/magento-setup-job -n $aks_namespace
# Apply Magento server Deployment
echo "Applying Magento server Deployment..."
curl -s "$file_base_url/magento/deployment.yaml?$sas_token" | sudo kubectl apply -n $aks_namespace -f -
# Apply Magento Cron Deployment
echo "Applying Magento cron Deployment..."
curl -s "$file_base_url/magento/cron.yaml?$sas_token" | sudo kubectl apply -n $aks_namespace -f -

# Deeploy Varnish (if required)
backend_service=""
backend_service_port=""
if [ "${VARNISH_CACHE_SWITCH}" = "true" ] || [ "${VARNISH_CACHE_SWITCH}" = "True" ]; then
  # Apply Varnish Configmap
  echo "Applying Varnish Configmap..."
  curl -s "$file_base_url/varnish/configmap.yaml?$sas_token" | sudo kubectl apply -n $aks_namespace -f -
  # Apply Varnish Services
  echo "Applying Varnish Services..."
  curl -s "$file_base_url/varnish/services.yaml?$sas_token" | sudo kubectl apply -n $aks_namespace -f -
  # Apply Varnish Deployment
  echo "Applying Varnish Deployment..."
  curl -s "$file_base_url/varnish/deployment.yaml?$sas_token" | sudo kubectl apply -n $aks_namespace -f -
  backend_service="varnish-service"
  backend_service_port="80"
else
  backend_service="magento-service"
  backend_service_port="8080"
fi

# Deploy tls (if required) and ingress
if [ "${TLS_SWITCH}" = "true" ] || [ "${TLS_SWITCH}" = "True" ]; then
  # Apply TLS Secret Provider
  echo "Applying TLS Secret Provider..."
  curl -s "$file_base_url/tls/secret-provider.yaml?$sas_token" | \
    sed -e "s/__USER_ASSIGNED_IDENTITY_ID__/${AKS_SECRET_PROVIDER_CLIENT_ID}/g" \
        -e "s/__KEYVAULT_NAME__/${KEYVAULT_NAME}/g" \
        -e "s/__CERTIFICATE_NAME__/${CERTIFICATE_NAME}/g" \
        -e "s/__TENANT_ID__/${TENANT_ID}/g" | \
    sudo kubectl apply -n "$aks_namespace" -f -

  # Certing TLS Cert Pod
  echo "Certing TLS Cert Pod..."
  curl -s "$file_base_url/tls/cert-pod.yaml?$sas_token" | sudo kubectl apply -n "$aks_namespace" -f -

  # Apply nginx Ingress with TLS
  echo "Applying nginx Ingress with TLS..."
  curl -s "$file_base_url/ingress/ingress-tls.yaml?$sas_token" | \
    sed -e "s/__FQDN__/${EXTERNAL_FQDN}/g" \
        -e "s/__SERVICE_NAME__/${backend_service}/g" \
        -e "s/__SERVICE_PORT__/${backend_service_port}/g" | \
    sudo kubectl apply -n "$aks_namespace" -f -
else
  # Apply nginx Ingress without TLS
  echo "Applying nginx Ingress without TLS..."
  curl -s "$file_base_url/ingress/ingress.yaml?$sas_token" | \
    sed -e "s/__SERVICE_NAME__/${backend_service}/g" \
        -e "s/__SERVICE_PORT__/${backend_service_port}/g" | \
    sudo kubectl apply -n "$aks_namespace" -f -
fi

# Ensure the log file is accessible
chmod 644 $LOG_FILE
echo "Log file can be found at: $LOG_FILE"

# Schedule VM deletion in 10 seconds
echo "Scheduled VM deletion in 10 seconds..."
nohup bash -c "sleep 10 && sudo az vm delete --resource-group $AZURE_RESOURCE_GROUP --name $VIRTUAL_MACHINE_NAME --yes --no-wait" > deploy-aks.log 2>&1 &
