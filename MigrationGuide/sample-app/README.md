# Sample Migration Application

This sample application is used as the starting point for learning how to migration an non-Azure based MySQL instance to Azure.  It is made up of two applications, a nodeJS-based web application and a Java-based API.

You can follow the steps in the MySQL Migration guide to deploy this application locally, and then migrate it to Azure.

## Artifacts

- Conference Demo (API) : A Java API that is called by the client.
- Conference Demo (Client) : A NodeJS web application.
- Database script : Script that is used to populate the MySQL database used in the Conference Demo apps and ultimately for migration to Azure.

## Landing Zone

There are two Azure ARM templates that will support the deployment and migration of this sample application:

- [MySQL Migration](../arm-templates/ExampleWithMigration/README.md)
- [MySQL Migration (Secure)](../arm-templates/ExampleWithMigrationSecure/README.md)