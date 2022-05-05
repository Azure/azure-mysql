# Utilize AKS and Azure Database for MySQL Flexible Server

Rather than managing the database volumes for a MySQL server instance, it is possible to utilize Azure Database for MySQL Flexible Server in order to use a platform as a service approach.  This will remove the need to have a database server container and a volumne to be persisted.

## Push images to Azure Container Registry

1. If they haven't already, push the images to the Azure Container Registry using the [Push Images to Acr](./../Misc/01_PushImagesToAcr.md) article.

## Run images in AKS

1. Review the `store-web-development.yaml` file
2. Run the following to execute the deployment, update the `DB_HOST` value to the Azure Database for MySQL flexible server instance:

  ```powershell
  kubectl create -f store-web-development.yaml
  ```
