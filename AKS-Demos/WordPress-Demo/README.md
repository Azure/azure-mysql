# WordPress Samples application with Azure Database for MySQL on Azure Kubernetes 

**NOTE: Azure Database for Flexible Server is in preview.**

You can use the application in [code](./Code) folder to install a fresh WordPress application when you follow [Wordpress on AKS with MySQL Flexible server tutorial](https://docs.microsoft.com/en-us/azure/mysql/flexible-server/tutorial-deploy-wordpress-on-aks). 

## Custom wp-config.php to use with Flexible server

This docker image has custom WordPress installation with custom [wp-config.php](./Code/public/wp-config.php). This file has environment variables for database information and includes SSL flag to connect to the database over SSL. Here is the code snippet :

```
$connectstr_dbhost = getenv('DATABASE_HOST');
$connectstr_dbname = 'flexibleserverdb';
$connectstr_dbusername = getenv('DATABASE_USERNAME');
$connectstr_dbpassword = getenv('DATABASE_PASSWORD');


define('DB_NAME', $connectstr_dbname);

/** MySQL database username */
define('DB_USER', $connectstr_dbusername);

/** MySQL database password */
define('DB_PASSWORD',$connectstr_dbpassword);

/** MySQL hostname */
define('DB_HOST', $connectstr_dbhost);

/** SSL*/
define('MYSQL_CLIENT_FLAGS', MYSQLI_CLIENT_SSL);
```
## Build your Docker image
You can build a docker image using [Dockerfile] (./code/Dockerfile).  Deploy your docker image to Docher hub or Azure Container registry.
Make sure you're in the directory my-wordpress-app in a terminal using the cd command. Run the following command to build image:

```
docker build --tag myblog:latest . 
```

Deploy your image to [Docker hub](https://docs.docker.com/get-started/part3/#create-a-docker-hub-repository-and-push-your-image) or [Azure Container registry](https://docs.microsoft.com/azure/container-registry/container-registry-get-started-azure-cli).

## Use the kubernetes manifest to apply 

Use the [wordpress.yaml](./wordpress.yaml) to apply using ```kubectl```. Replace``` [DOCKER-HUB-USER/ACR ACCOUNT]/[YOUR-IMAGE-NAME]:[TAG]``` with your actual WordPress docker image name and tag, for example docker-hub-user/myblog:latest.
Update env section below with your **SERVERNAME, YOUR-DATABASE-USERNAME, YOUR-DATABASE-PASSWORD** of your MySQL flexible server.

Deploy this manifest file using ```kubectl apply -f wordpress.yaml```
