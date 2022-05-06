# Deploy Azure Function App to Azure Kubernetes Service (AKS)

Function apps can be containerized and deployed to AKS.  These steps will walk through this process so it can be applied later if this is something the architecture demands.

## Ensure Docker is started

- Open Docker Desktop, ensure that it is running.

## Setup AKS (KEDA)

- Open a new Visual Studio Code window to the `C:\labfiles\microsoft-mysql-developer-guide\Artifacts\06-03-FunctionApp-AKS` folder
- Open a new terminal window, ensure that an AKS connection is present:

```Powershell
$resourceGroupName = "YOUR_RESOURCEGROUP_NAME";

az aks install-cli

az aks get-credentials --name "mysqldevSUFFIX" --resource-group $resourceGroupName
```

- Run the following command to install KEDA on the AKS cluster:

```PowerShell
kubectl create namespace keda

func kubernetes install
```

## Ensure Docker Connection

1. Open the Azure Portal
2. Browse to the **mysqldevSUFFIX** Azure Container Registry
3. Under **Settings**, select **Access keys**
4. Copy the username and password
5. In the terminal windows, run the following:

    ```powershell
    docker login {acrName}.azurecr.io -u {username} -p {password}
    ```

## Configure Function App as Container

- Run the following command to setup the docker file

```PowerShell
func init --docker-only --python
```

- Deploy the function app using the following, be sure to replace the function name and `SUFFIX` value:

```PowerShell
func kubernetes deploy --name "addcustomerfunction" --registry "mysqldevSUFFIX.azurecr.io"
```

- After following the above steps, the function app has been turned into a container and pushed to the target registry.  It should also now be deployed to the AKS cluster in the `keda` namespace.
