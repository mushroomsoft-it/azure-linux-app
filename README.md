# Terraform Azure Linux Web App

This folder contains the create azure linux web app example of a [Terraform](https://www.terraform.io/) file on Azure Web Apps.

This Terraform file create an Azure Web App with Insights and using a docker container on Microsoft Azure by provisioning the necessary infrastructure.

## Requirements

* You must have a [Microsoft Azure](https://azure.microsoft.com/) subscription.

* You must have the following installed:
  * [Terraform](https://www.terraform.io/) CLI
  * Azure CLI tool

* The code was written for:
  * Terraform 0.14 or later

* It uses the Terraform AzureRM Provider v 3.1 that interacts with the many resources supported by Azure Resource Manager (AzureRM) through its APIs.

## Using the code

* Configure your access to Azure.

  * Authenticate using the Azure CLI.

    Terraform must authenticate to Azure to create infrastructure.

    In your terminal, use the Azure CLI tool to setup your account permissions locally.

    ```bash
    az login  
    ```

    Your browser will open and prompt you to enter your Azure login credentials. After successful authentication, your terminal will display your subscription information.

    You have logged in. Now let us find all the subscriptions to which you have access...

    ```bash
    [
      {
        "cloudName": "<CLOUD-NAME>",
        "homeTenantId": "<HOME-TENANT-ID>",
        "id": "<SUBSCRIPTION-ID>",
        "isDefault": true,
        "managedByTenants": [],
        "name": "<SUBSCRIPTION-NAME>",
        "state": "Enabled",
        "tenantId": "<TENANT-ID>",
        "user": {
          "name": "<YOUR-USERNAME@DOMAIN.COM>",
          "type": "user"
        }
      }
    ]
    ```

    Find the `id` column for the subscription account you want to use.

    Once you have chosen the account subscription ID, set the account with the Azure CLI.

    ```bash
    az account set --subscription "<SUBSCRIPTION-ID>"
    ```

  * Create a Service Principal.

    A Service Principal is an application within Azure Active Directory with the authentication tokens Terraform needs to perform actions on your behalf. Update the `<SUBSCRIPTION_ID>` with the subscription ID you specified in the previous step.

    Create a Service Principal:

    ```bash
    az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/<SUBSCRIPTION_ID>"

    Creating 'Contributor' role assignment under scope '/subscriptions/<SUBSCRIPTION_ID>'
    The output includes credentials that you must protect. Be sure that you do not include these credentials in your code or check the credentials into your source control. For more information, see https://aka.ms/azadsp-cli
    {
      "appId": "xxxxxx-xxx-xxxx-xxxx-xxxxxxxxxx",
      "displayName": "azure-cli-2022-xxxx",
      "password": "xxxxxx~xxxxxx~xxxxx",
      "tenant": "xxxxx-xxxx-xxxxx-xxxx-xxxxx"
    }
    ```
    If you have a single subscrition, you can use the following script
    ```bash
    ./scripts/setup.bash > credentials.json
    ```
    This will store your credentials in a credentials.json

* Initialize working directory.
  Go to the scr folder. Then the first command that should be run after writing a new Terraform configuration is the `terraform init` command in order to initialize a working directory containing Terraform configuration files. It is safe to run this command multiple times.

  ```bash
  terraform init
  ```

* Configure project.

  All the tf configurations are defined as  input variables in `vars.tf` file

  If you want to modify both you will be able to do it in several ways, but be sure to replace the value of `<YOUR_VARIABLE_NAME>` with the corresponding setting:

  * Loading variables from command line option.

    Run Terraform commands in this way:

    ```bash
    terraform plan -var 'variable_name=<YOUR_VARIABLE_NAME>' -var 'variable_name=<YOUR_VARIABLE_NAME>'
    ```

    ```bash
    terraform apply -var 'variable_name=<YOUR_VARIABLE_NAME>' -var 'variable_name=<YOUR_VARIABLE_NAME>'
    ```

  * Loading variables from a file.

    When Terraform runs it will look for a file called `terraform.tfvars`. You can populate this file with variable values that will be loaded when Terraform runs. An example for the content of the `terraform.tfvars` file:

    ```bash
    variable_name="<YOUR_VARIABLE_NAME>"
    ```

  * Loading variables from environment variables.

    Terraform will also parse any environment variables that are prefixed with `TF_VAR`. You can create environment variables using `TF_VAR_variable_name`:

    ```bash
    export TF_VAR_variable_name=<YOUR_VARIABLE_NAME>
    ```

 
* Validate the changes.

  The `terraform plan` command lets you see what Terraform will do before actually making any changes.

  Run command:

  ```bash
  terraform plan
  ```

* Apply the changes.

  The `terraform apply` command lets you apply your configuration and it creates the infrastructure.

  Run command:

  ```bash
  terraform apply
  ```

* Test the changes.

  When the `terraform apply` command completes, use the Azure console, you should see:
  
  * The new Azure storage account.

  * The new Blob Storage container created in the Azure storage account.

* Clean up the resources created.

  When you have finished, the `terraform destroy` command destroys the infrastructure you created.
  
  Run command:

  ```bash
  terraform destroy
  ```