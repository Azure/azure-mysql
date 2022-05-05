## Running the sample application

Instead of learning multiple sample applications, the guide focused on evolving deployment strategies. Readers should learn the sample application structure once and focus on how the application will need to be modified to fit the deployment model.

### Site map

![](media/sample-app-site-map.png)

### Sample Application Prerequisites

- Azure subscription
- Git
- MySQL Workbench

### Quick start: manual Azure set up instructions

As part of this guide, there are environment automation setup scripts provided that will build and configure much of the environment needed for the sample application. It is important to understand the basic Azure **concepts** before running the automated scripts. Walking through each step will help provide additional context and learning opportunities. The scripts will create an environment in a few minutes rather than requiring to walk through lengthy setup exercises.

>**Note:** The sample application was tested with PHP version 7.4 and 8.0. Deploying to an 8.x environment requires a slightly different configuration as the underlying web server has changed.

| PHP Version | Web Server |
|-------------|----------------|
| 7.4         | Apache         |
| 8.0         | Nginx          |

The Azure App Service uses this [Docker image](https://github.com/Azure-App-Service/nginx-fpm) for its 8.0 container builds.

>![Warning](media/warning.png "Warning") **Warning**: Outdated runtimes are periodically removed from the Web Apps Create and Configuration blades in the Portal. These runtimes are hidden from the Portal when they are deprecated by the maintaining organization or found to have significant vulnerabilities. These options are hidden to guide customers to the latest runtimes where they will be the most successful. Older Azure App Service Docker images can be found [here](https://github.com/Azure-App-Service/php).

### Sample application deployment steps

**Deploying to PHP 8.0**

The deployment strategy applied in this sample application focuses on updating project environment variables instead of global environment variable configuration.

1. Log into the Azure Portal.
2. Search for Marketplace.
3. While in the Marketplace, search for and create Azure Web App + Database resources in the Marketplace.

   - Select the Marketplace button.
  
      ![Displays the Marketplace button.](media/market-place-button.png "Marketplace button")

   - Enter `Web App + Database` in the search box.
   - Select the Microsoft Web App + Database search result.

      ![Web app + database search result.](media/microsoft-web-app-database-marketplace.png)

3. Create a web application and database.

    ![Create web app database.](media/create-web-app-database.png "Create Web App + Database")

   - Choose the subscription.

   - Create a new resource group

   - Choose a region.

   - Create a unique web app name.

   - Select the runtime stack.  The web app is only tested with PHP 8.0.

   - Create the resources.

4. After the resources have been deployed, locate the App Service in the Resource Group.
  
   - Select the **Deployment Center** and capture the configuration settings.

   - In the Settings tab, choose Local Git.

    ![App Service repository options.](media/local-git.png)

   - Select **Save** at the top.

    >**Note:** Alternative Azure CLI command:

    ```cmd
    az webapp deployment source config-local-git --name <app-name> --resource-group <group-name>
    ```

   - Capture the **Git Clone Uri**. Later exercises will be pushing the application files to the Azure App Service local storage from the development machine.
  
      ![Local Git URL example](media/local-git-url.png)

   - Capture the Application Scope user and password to be used later. Make sure to capture only the user name.

     ![Application Scope user and password](media/application-scope-user-password.png)

5. Clone the sample **ContosoNoshNow** application to the local development machine from the Microsoft Git repository:

TODO: Get the MS repo.

   - Open the command prompt or terminal on the development machine.

   - Type the following commands individually to configure the remote repo connection. Review the output:

      ```cmd
      git remote add azure <Azure App Service Git Clone URL>
      git remote -v
      git push azure master
      ```
  
   - When pushing content to the Azure App Service, the systems will prompt for the Local Git credentials. Enter the Application Scope credentials.
  
      ![Git Credential Manager](media/git-credential-manager-for-windows.png)

      If you make a mistake entering the credentials, you will have to open Credential Manager to update the credentials.

   - The following output should display in the command window:

      ![Azure local git push example.](media/azure-local-git-push.png)

5. Return to the Azure Portal. Navigate to the App Service. Find the **Deployment Tools** section. Log into App Service SSH terminal.

   ![](media/ssh_terminal.png)

6. Verify the sample application files have been copied into the wwwroot directory.

   ```bash
   cd /home/site/wwwroot
   ls -la
   ```

7. Run the Composer update command in the wwwroot directory, which will import the packages and create the vendor folder, along with the autoload script (../vendor/autoload.php).

    ```bash
    cp /home/site/repository/.env.example.azure /home/site/wwwroot/.env
    composer.phar update
    ```
  
8. Generate Laravel application key. This command will update the **.env** file.
  
    ```bash
    php artisan key:generate
    ```

9. Update the **APP_URL** parameter in the .env file with the Azure App Service URL and save the changes.

   ```bash
    nano /home/site/wwwroot/.env
   ```

    ![Update APP_URL value](media/update-app-url-env.png)

10. Copy the Nginx default to the home default. By default, App Service set WEBSITES_ENABLE_APP_SERVICE_STORAGE = true.  Files stored in /home path are persisted in an Azure Storage file share, which can survive restart and shared across scale instances. So we need to save your own Nginx configure file under /home path.

      ```bash
      cp /etc/nginx/sites-enabled/default /home/default
      ```

11. Update the Nginx home default.

      ```bash
      nano /home/default
      ```

      - absolute_redirect off
      - root /home/site/wwwroot/public
      - try_files $uri $uri/ /index.php$is_args$args;
  
      ![](media/nginx-home-default-update.png)

12. Restart the service.

      ```bash
      service nginx restart
      ```

13. Your configuration needs to survive an App Service restart. Update the App Service Startup Command.

       - Navigate to the **Settings** section.
       - Select **Configuration**.
       - Select the **General settings**.
       - Enter the following command in the **Startup Command**:
  
      ```bash
      cp /home/default /etc/nginx/sites-enabled/default; service nginx restart
      ```

      ![](media/general-settings-startup-command.png)

14. Open a browser and view the application.

    ![ContosoNoshNow home page](media/ContosoNoshNow-home-page.png)

   >**Note:** Notice the message in red at the bottom of the web page. "Site is unable to pull from database. Using JSON data instead."

## Connecting to the database

The application should now be available and show some sample data, however the web application is not reading or writing to the database. Let's go through the steps to configure the database configuration information.

1. Capture the database connection information. Open the Azure CLI Cloud Shell and run this command.

   ```cmd
   az webapp deployment list-publishing-profiles --resource-group <resource group name> --name <app service name>
   ```

2. Capture the following connection values:
   - Host/Server
   - User ID
   - Password
  
   >**Note:** For production environments, values will be retrieved from Azure Key Vault.

3. Using the Azure Portal, navigate to the Flexible Server in the resource group and create the `contosonoshnow` database.  

   ![](media/create-contosonoshnow-database.png)

   >**Note:** It is possible to execute alternative commands in the App Service SSL terminal to create the database. See the alternative commands below.

   Alternative commands:

   ```bash
   mysql --host=<hostname>-server.mysql.database.azure.com --user=<user name> --password=<password> --ssl=true
   ```

   ```sql
   CREATE DATABASE contosonoshnow
   ```

   ```bash
   exit
   ```

4. With the database connection information in hand, open the App Service SSH console and configure the **.env** project file.

   ```bash
   nano /home/site/wwwroot/.env
   ```

   ![Configure the database environment variables.](media/update-mysql-connection-info.png)

   Update the following environment variables:
   - DB_HOST
   - DB_DATABASE
   - DB_USERNAME
   - DB_PASSWORD
  
5. Run the `php artisan migrate` command to create the tables in the contosonoshnow database.

   ```bash
   php artisan migrate
   ```

   ![](media/php-laravel-database-creation.png)

6. Run the `php artisan db:seed` command to seed the database with sample data values.

   ```bash
   php artisan db:seed
   ```

   ![Seeded database.](media/seeded-database.png)

   - Using MySQL Workbench, verify the tables have the seed data.

7. Navigate back to the web app and enter a sample order.

   ![](media/sample-order.png)

8. Using MySQL Workbench, verify the order was saved to the Flexible Server database.

   ![](media/verify-order-data.png)

### What happens to my app during an Azure deployment?

All the officially supported deployment methods make changes to the files in the /home/site/wwwroot folder of the app. These files are used to run the application. The web framework of  choice may use a subdirectory as the site root. For example, Laravel, uses the public/ subdirectory as the site root.

The environment variable could be set globally or at the project level. Setting the environment variables at the project level, when possible, allows for deployment independence and reduces the likelihood of dependency collision.

### Troubleshooting tips

- Select the App Service in the Azure Portal. In the **Monitoring** section, select **Log Stream**.
- [Troubleshoot connection issues to Azure Database for MySQL](https://docs.microsoft.com/en-us/azure/mysql/howto-troubleshoot-common-connection-issues)
- Running `php -i` at the Azure App Service SSH console will provide valuable configuration information.
- Azure App Service 8.0 php.ini location - `cat /usr/local/etc/php/php.ini-production`
- [Configure a PHP app for Azure App Service - Access diagnostic logs](https://docs.microsoft.com/en-us/azure/app-service/configure-language-php?pivots=platform-linux#access-diagnostic-logs)
- [Deploying a Laravel application to Nginx server.](https://laravel.com/docs/8.x/deployment#nginx)
- [Local Git deployment to Azure App Service](https://docs.microsoft.com/en-us/azure/app-service/deploy-local-git?tabs=cli)

## Recommended content

- [How PHP apps are detected and built.](https://github.com/microsoft/Oryx/blob/main/doc/runtimes/php.md)
