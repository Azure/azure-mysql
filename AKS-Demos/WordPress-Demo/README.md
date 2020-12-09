# WordPress Samples application with Azure Database for MySQL on Azure Kubernetes 

**NOTE: Azure Database for Flexible Server is in preview. **

You can use the application in [code](/Code) folder to install a fresh WordPress application when you follow [Wordpress on AKS with MySQL Flexible server tutorial](https://docs.microsoft.com/en-us/azure/mysql/flexible-server/tutorial-deploy-wordpress-on-aks). You can build a docker image using [/code/Dockerfile].

## Custom wp-config.php to use with Flexible server

This docker image has custom WordPress installation with custom [./Code/public/wp-config.php). This file has environment variables for database information and includes SSL flag to connect to the database over SSL. Here is the code snippet :

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

## Use the kubernetes manifest to apply 

Use the [wordpress.yaml](wordpress.yaml) to apply using ```kubectl```. Replace [DOCKER-HUB-USER/ACR ACCOUNT]/[YOUR-IMAGE-NAME]:[TAG] with your actual WordPress docker image name and tag, for example docker-hub-user/myblog:latest.
Update env section below with your SERVERNAME, YOUR-DATABASE-USERNAME, YOUR-DATABASE-PASSWORD of your MySQL flexible server.

Deploy this manifest file using ```kubectl apply -f wordpress.yaml```
