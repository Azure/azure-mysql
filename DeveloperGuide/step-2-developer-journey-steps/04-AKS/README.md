# Migrate to Azure Kubernetes Services (AKS)

Now that a containerized version of the applications exists, it can now be hosted in several places in Azure. Here we explore Azure App Service Containers.

## Push images to Azure Container Registry

1. If they haven't already, push the images to the Azure Container Registry using the [Push Images to Acr](./../Misc/01_PushImagesToAcr.md) article.

## Run images in Azure Kubernetes Service (AKS)

1. Open the `C:\labfiles\microsoft-mysql-developer-guide\Artifacts\04-AKS` directory with Visual Studio Code
2. Open a new terminal window, ensure kubectl is installed:

    ```powershell
    $resourceGroupName = "YOUR_RESOURCEGROUP_NAME";

    az aks install-cli

    az aks get-credentials --name "mysqldevSUFFIX" --resource-group $resourceGroupName
    ```

3. Run the following commands to deploy the containers (be sure to update the variable values):

    ```powershell
    $acrName = "mysqldevSUFFIX";
    $resourceName = "mysqldevSUFFIX";
    $resourceGroupName = "RESOURCEGROUPNAME";

    $acr = Get-AzContainerRegistry -Name $acrName -ResourceGroupName $resourceGroupName;
    $creds = $acr | Get-AzContainerRegistryCredential;
    
    kubectl create namespace mysqldev

    $ACR_REGISTRY_ID=$(az acr show --name $ACRNAME --query "id" --output tsv);
    $SERVICE_PRINCIPAL_NAME = "acr-service-principal";
    $PASSWORD=$(az ad sp create-for-rbac --name $SERVICE_PRINCIPAL_NAME --scopes $ACR_REGISTRY_ID --role acrpull --query "password" --output tsv)
    $USERNAME=$(az ad sp list --display-name $SERVICE_PRINCIPAL_NAME --query "[].appId" --output tsv)

    kubectl create secret docker-registry acr-secret `
    --namespace mysqldev `
    --docker-server="https://$($acr.loginserver)" `
    --docker-username=$username `
    --docker-password=$password

    #ensure that MSI is enabled
    az aks update -g $resourceGroupName -n $resourceName --enable-managed-identity

    #get the principal id
    az aks show -g $resourceGroupName -n $resourceName --query "identity"
    ```

4. Create a managed disk, copy its `id` for later use:

  ```powershell
  az disk create --resource-group $resourceGroupName --name "disk-store-db" --size-gb 200 --query id --output tsv
  ```

5. Open and review the following `storage-db.yaml` deployment file:

  ```yaml
  apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    name: mysql-data
    namespace: mysqldev
  spec:
    accessModes:
    - ReadWriteOnce
    resources:
      requests:
        storage: 200Gi
  ```

6. Open and review the `store-db.yaml` deployment file, be sure to replace the `<REGISTRY_NAME>` and `ID` tokens:

  ```yaml
  apiVersion: v1
  kind: Pod
  metadata:
    name: store-db
    namespace: mysqldev
    labels:
        app: store-db
  spec:
    volumes:
    - name: mysql-data
      persistentVolumeClaim:
        claimName: mysql-data
    containers:
      - name: store-db
        image: <REGISTRY_NAME>.azurecr.io/store-db:latest
        volumeMounts:
        - mountPath: "/var/lib/mysql/"
          name: mysql-data
        imagePullPolicy: IfNotPresent
        env:
        - name: MYSQL_DATABASE
          value: "ContosoStore"
        - name: MYSQL_ROOT_PASSWORD
          value: "root"
    imagePullSecrets:
      - name: acr-secret
  ```

7. Run the deployment:

    ```powershell
    kubectl create -f storage-db.yaml

    kubectl create -f store-db.yaml
    ```

8. Create the following `store-web.yaml` deployment file, be sure to replace the `<REGISTRY_NAME>` token:

  ```yaml
  apiVersion: v1
  kind: Pod
  metadata:
    name: store-web
    namespace: mysqldev
  spec:
    containers:
      - name: store-web
        image: <REGISTRY_NAME>.azurecr.io/store-web:latest
        imagePullPolicy: IfNotPresent
        env:
        - name: DB_DATABASE
          value: "ContosoStore"
        - name: DB_USERNAME
          value: "root"
        - name: DB_PASSWORD
          value: "root"
        - name: DB_HOST
          value: "store-db"
    imagePullSecrets:
      - name: acr-secret
  ```

6. Run the deployment:

    ```powershell
    kubectl create -f store-web.yaml
    ```

## Add services

1. Open and review the  `store-db-service.yaml` yaml file:

  ```yaml
  apiVersion: v1
  kind: Service
  metadata:
    name: store-db
  spec:
    ports:
    - port: 3306
    selector:
      app: store-db
  ```

2. Open and review the `store-web-service.yaml` yaml file:

  ```yaml
  apiVersion: v1
  kind: Service
  metadata:
    name: store-web
  spec:
    ports:
    - port: 80
    selector:
      app: store-web
  ```

3. Run the deployment:

    ```powershell
    kubectl create -f store-web-service.yaml

    kubectl create -f store-db-service.yaml
    ```

## Create a Loadbalancer

1. Review the `store-web-lb.yaml` file:
2. Execute the deployment:

  ```powershell
  kubectl create -f store-web-lb.yaml
  ```

3. Review the `store-db-lb.yaml` file:
4. Execute the deployment:

  ```powershell
  kubectl create -f store-db-lb.yaml
  ```

## Test the images

1. Browse to the Azure Portal
2. Navigate to the AKS cluster and select it
3. Under **Kubernetes resources**, select **Service and ingresses**
4. For the **store-web-lb** service, select the external IP link. A new web browser tab should open to the web front end. Ensure that an order can be created without a database error.

## Create a deployment

Kubernetes deployments allow for the creation of multiple instances of pods and containers in case nodes or pods crash unexpectiantly.  

1. Review the `store-web-deployment.yaml` file be sure to replace the Azure Container Registry link:

  ```powershell
  kubectl create -f store-web-deployment.yaml
  ```

2. Review the `store-db-deployment.yaml` file be sure to replace the Azure Container Registry link:
3. Execute the deployment:

  ```powershell
  kubectl create -f store-db-deployment.yaml
  ```

4. This deployment is now very robust and will survive multiple node failures.
