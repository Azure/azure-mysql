# The Azure Database for MySQL Developer Guide overview

Welcome to THE comprehensive guide to developing MySQL-based applications on Microsoft Azure! Whether creating a production application or improving an existing enterprise system, this guide will take developers and architects through the fundamentals of MySQL application development to more advanced architecture and design. From beginning to end, it is a content journey designed to help ensure current or future MySQL systems are performing at their best even as their usage grows and expands.

The topics and flow contained in this guide cover the advantages of migrating to or leveraging various simple to use, valuable Azure cloud services in MySQL architectures. Be prepared to learn how easy and quick it is to create applications backed by Azure Database for MySQL.

## Guide and artifacts

To use the samples in this repo, download the Developer Guide from https://aka.ms/mysqldevguide. The guide references artifact directories, Step 0 to Step 2.

- **Step 0:** This directory contains the main **sample-php-app** application. This application is referenced in the evolution tutorials. Reviewing the application now, allows the readers to focus on the adjustments to the architecture.  It is designed to be the fastest method to get acquainted with Azure services using a working PHP application without having to step through each tutorial in the Step 2 repo directory. The **sample-php-app-rest** application is evolved version utilizing a Java REST microservice AKS architecture. Again, these are high-level concept exercises.

- **Step 1:** This directory contains the set up for your development environment referenced in Step 2. Readers **cannot** skip this step if they wish to try tutorials in Step 2.
  
- **Step 2:** This directory contains the progressive tutorial examples based on the Sample Application content. If you currently have an on-premises MySQL application that needs to be migrated, then consider starting with the [Classic Deployment to PHP enabled IIS server](https://github.com/Azure/azure-mysql/tree/master/DeveloperGuide/step-2-developer-journey-steps/01-ClassicDeploy). The first two tutorials in this directory provide a feeling of the lift and shift experience. Readers who are more interested in the new application deployment experience can start on [Cloud Deployment to Azure App Service](https://github.com/Azure/azure-mysql/tree/master/DeveloperGuide/step-2-developer-journey-steps/02-02-CloudDeploy-AppSvc).
