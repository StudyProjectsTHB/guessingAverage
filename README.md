[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=eineOrganisation_guessingAverage&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=eineOrganisation_guessingAverage)
![CI Maven](https://github.com/eineOrganisation/guessingAverage/actions/workflows/maven.yml/badge.svg)

# guessingAverage

## Requirements

### Build Locally
* Java 17
* Maven 4.0.0

### Deploy to AWS
* Terraform 1.6.0

## Installation
### Build Locally
1. Clone the repository
```shell
git clone https://github.com/eineOrganisation/guessingAverage.git
```
2. Build the project
```shell
mvn clean install
```
3. Run the project
```shell
# Just don't do it. It won't work anyway. (No access to a PostgreSQL database)
mvn spring-boot:run
```

### Deploy to AWS

1. Clone the repository
   ```shell
   git clone https://github.com/eineOrganisation/guessingAverage.git
   ```

2. Move into the cloned repository
   ```shell
   cd guessingAverage
   ```

3. Create variables.auto.tfvars
   ```shell
   # Windows
   .\create_tfvars.cmd
   ```
   ```shell
   # Unix
   bash ./create_tfvars.sh
   ```

4. Write your credentials into terraform\variables.auto.tfvars

   + aws_access_key_id: Your AWS Access Key ID
   + aws_secret_access_key: Your AWS Secret Access Key
   + aws_session_token: Your AWS Session Token
   + aws_db_password: The password for the PostgreSQL database, e.g. "guessingAverage_password"
   + aws_db_user: The username for the PostgreSQL database, e.g. "guessingAverage_user"
   + aws_ec2_public_key: Your public key for the EC2 instances
   + github_token: Your [GitHub token](https://github.com/settings/tokens/new), it must have the scope "admin:repo_hook"
   + github_repository: The repository where the webhook will be created, it is already set to "guessingAverage"
   + github_repository_owner: The owner of the repository, it is already set to "eineOrganisation"
   + github_webhook_secret: The secret for the webhook (not implemented yet, maybe available in th future)

5. Move into the terraform directory
   ```shell
   cd terraform
   ```

6. Initialize Terraform
   ```shell
   terraform init
   ```
7. Test your credentials
   ```shell
   terraform plan
   ```

8. Deploy the project
   ```shell
   terraform apply --auto-approve
   ```
   + The DNS name of the load balancer will be printed to the console. You can access the application via this URL.

9. Destroy the project
   ```shell
   terraform destroy --auto-approve
   ```
   
## Features
+ Maybe later idk

## TODO
+ AMI for launch configuration
+ GitHub Webhook Secret
+ Exception Handing for Webhook Lambda
