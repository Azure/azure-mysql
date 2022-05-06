# Migrate to Docker Containers

This is a simple app that runs PHP code to connect to a MYSQL database.  Both the application and database are deployed via Docker containers.

## Migrate Application to Docker

### Migrate to ENV variables

1. Switch to Visual Studio Code and the opening repo directory
2. Open the `.\artifacts\sample-php-app\public\database.php` file, update the php MySQL connection environment variables by removing the `APPSETTING_` from each:

    ```php
    $servername = getenv("DB_SERVERNAME");
    $username = getenv("DB_USERNAME");
    $password = getenv("DB_PASSWORD");
    $dbname = getenv("DB_DATABASE");
    ```

### Download Docker container

1. Open Docker Desktop, if prompted, select **OK**
2. In the agreement dialog, select the checkbox and then select  **Accept**
3. It will take a few minutes for the Docker service to start, when prompted, select **Skip tutorial**
4. Open a PowerShell window, run the following to download and start a php-enabled docker container

    ```Powershell
    docker run -d php:8.0-apache
    ```

5. In the `c:\labfiles\microsoft-mysql-developer-guide\artifacts\03-00-Docker` directory, create the `Dockerfile.web` with the following:

    ```text
    # Dockerfile
    FROM php:8.0-apache

    RUN apt-get update && apt-get upgrade -y
    RUN apt update && apt install -y zlib1g-dev libpng-dev && rm -rf /var/lib/apt/lists/*
    RUN apt update && apt install -y curl
    RUN apt-get install -y libcurl4-openssl-dev
    RUN docker-php-ext-install fileinfo
    RUN docker-php-ext-install curl
    RUN docker-php-ext-install mysqli
    RUN docker-php-ext-enable mysqli
    RUN docker-php-ext-install pdo_mysql
    
    COPY ./000-default.conf /etc/apache2/sites-available/000-default.conf
    COPY ./start-apache.sh /usr/local/bin

    RUN a2enmod rewrite

    COPY ./sample-php-app /var/www
    RUN chown -R www-data:www-data /var/www

    RUN chmod 755 /usr/local/bin/start-apache.sh

    #CMD ["start-apache.sh"]

    EXPOSE 80
    ```

6. Run the following to create the image:

    ```PowerShell
    $sourcePath = "c:\labfiles\microsoft-mysql-developer-guide";

    cd $sourcePath;

    docker build -t store-web --file artifacts\Dockerfile.web . 
    ```

## Migrate Database to Docker

1. Run the following to export the database:

    ```powershell
    cd "c:\labfiles\microsoft-mysql-developer-guide";

    $username = "root";
    $password = "";
    $server = "localhost";
    $database = "ContosoStore";

    $mysqlPath = "C:\Program Files\MySQL\MySQL Workbench 8.0 CE"

    & "$mysqlPath\mysqldump" -h $server -u $username $database > data.sql

    #remove the weird encoding...
    $data = get-content data.sql

    set-content data.sql $data
    ```

2. In the `c:\labfiles\microsoft-mysql-developer-guide\artifacts` directory, create a new `Dockerfile.db` docker compose file:

    ```text
    FROM mysql:8.0
    RUN chown -R mysql:root /var/lib/mysql/

    ADD data.sql /etc/mysql/data.sql

    RUN cp /etc/mysql/data.sql /docker-entrypoint-initdb.d

    EXPOSE 3306
    ```

3. Build the container:

    ```PowerShell
    docker build -t store-db --file Dockerfile.db .
    ```

## Run the Docker images

1. Create the following `docker-compose.yml` docker compose file:

    ```yaml
    version: '3.8'
    services:
      web:
        image: store-web
        environment:
          - DB_DATABASE=contosostore
          - DB_USER=root
          - DB_PASSWORD=root
          - DB_PORT=3306
          - DB_SERVERNAME=db
        ports:
          - "8080:80"
      db:
        image: store-db
        restart: always
        environment:
          - MYSQL_ROOT_PASSWORD=root
        ports:
          - "3306:3306"
      phpmyadmin:
        image: phpmyadmin/phpmyadmin
        ports:
            - '8081:80'
        restart: always
        environment:
            PMA_HOST: db
        depends_on:
            - db
   ```

2. Run the following to create the web container:

    ```PowerShell
    cd Artifacts

    iisreset /stop

    docker compose run --service-ports web
    ```

3. Run the following to create the db container:

    ```powershell
    stop-service mysql

    docker compose run --service-ports db
    ```

4. Run the following to create the phpmyadmin container:

    ```powershell
    docker compose run --service-ports phpmyadmin
    ```

## Migrate the database

1. Use export steps in [Migrate the database](./Misc/02_MigrateDatabase) article to export the database
2. Open a browser to `http:\\localhost:8081` and the phpmyadmin portal
3. Login to the database using `root` and `root`
4. Select the **contosostore** database
5. Run the exported database sql to import the database and data
6. Select the **SQL** tab, copy and then run the following query by selecting **Go**, record the count

  ```sql
  select count(*) from `orders`
  ```

## Test the Docker images

1. Open a browser to `http:\\localhost:8080\index.php`
2. Select **START ORDER**

  > **NOTE** If  get an error about the application not being able to connect, do the following to attempt to debug:

  - Open a new PowerShell window, run the following to start a bash shell

    ```powershell
    docker exec -it artifacts-web-1 /bin/bash
    ```

  - Run the following commands in the new bash shell, look for the database error that is displayed:

    ```bash
    cd /var/www
    
    php artisian migrate
    ```

3. Once the connection is working, refresh the page then select **START ORDER**
4. Select **Breakfast**, then select **CONTINUE**
5. Select **Bacon & Eggs**, then select **ADD**
6. Select **CHECKOUT**
7. Select **COMPLETE ORDER**
8. Switch to the PowerShell window that started the containers, shutdown the images, press **CTRL-X** to stop the images
9. Restart the images:

    ```PowerShell
    docker compose up
    ```

10. Switch back to the phpmyadmin window.  Attemp to re-run the query, notice that the database has the same orders as when it was started before.  This is because the container's data was lost when it was stopped/removed.

## Fix Storage persistence

1. Modify the `docker-compose.yml` docker compose file, notice how we are creating and adding a volume to the database container.  We also added the phpmyadmin continer:

  ```yaml
  version: '3.8'
  services:
    web:
      image: store-web
      environment:
        - DB_DATABASE=contosostore
        - DB_USERNAME=root
        - DB_PASSWORD=root
        - DB_HOST=db
        - DB_PORT=3306
        - MYSQL_ATTR_SSL_CA=
      ports:
        - "8080:80" 
    db:
      image: store-db
      restart: always
      environment:
        - MYSQL_ROOT_PASSWORD=root
        - MYSQL_DATABASE=contosostore
      volumes:
        - "db-volume:/var/lib/mysql"
      ports:
        - "3336:3306"
    phpmyadmin:
      image: phpmyadmin/phpmyadmin
      ports:
          - '8081:80'
      restart: always
      environment:
          PMA_HOST: db
      depends_on:
          - db
  volumes:
    db-volume:
      external: false
   ```

## Re-test the Docker images

1. Run the following:

  ```PowerShell
  stop service mysql

  docker compose up
  ```

2. Create some more orders, restart the containers.  Notice that data is now persisted.  It is now up to the administrators to ensure the database volume is maintained for the length of the solution.  If this volume is ever deleted, the data will be lost!

## Save the images to Azure Container Registry (ACR)

1. Open the Azure Portal
2. Browse to the **mysqldevSUFFIX** Azure Container Registry
3. Under **Settings**, select **Access keys**
4. Copy the username and password
5. In the **paw-1** virtual machine, switch to a powershell window and run the following:

    ```powershell
    docker login {acrName}.azurecr.io -u {username} -p {password}

    docker tag phpmyadmin/phpmyadmin {acrName}.azurecr.io/phpmyadmin/phpmyadmin

    docker tag store-db {acrName}.azurecr.io/store-db

    docker tag store-web {acrName}.azurecr.io/store-web

    docker push {acrName}.azurecr.io/store-db

    docker push {acrName}.azurecr.io/store-web

    docker push {acrName}.azurecr.io/phpmyadmin/phpmyadmin
    ```

6. Three images should display in the Azure Container Registry that we will use later for deployment to other container based runtimes.
