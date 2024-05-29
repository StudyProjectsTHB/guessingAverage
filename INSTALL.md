[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=StudyProjectsTHB_guessingAverage&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=StudyProjectsTHB_guessingAverage)
![CI Maven](https://github.com/StudyProjectsTHB/guessingAverage/actions/workflows/maven.yml/badge.svg)

# GuessingAvg - Na, heute schon geraten?

## [Documentation](README.md)

# Installation

## Requirements

### Build Locally
* Java 17
* Maven 4.0.0
* PostgreSQL 16

### Deploy to AWS
* Terraform 1.6.0
* Python 3.9.13

## Installation
### Build Locally

1. Clone the repository
   ```shell
   git clone https://github.com/StudyProjectsTHB/guessingAverage.git
   ```
2. Build the project
   ```shell
   mvn clean install
   ```
3. Set enviroment variables DATABASE_HOST, DATABASE_NAME, DATABASE_USER and DATABASE_PASSWORD
4. Run the project
   ```shell
   mvn spring-boot:run
   ```

### Deploy to AWS

+ Only tested with Windows

1. Clone the repository
   ```shell
   git clone https://github.com/StudyProjectsTHB/guessingAverage.git
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
    + aws_ec2_public_key: Your OpenSSH public key for the EC2 instances, you will need to generate your own
    + github_token: Your [GitHub token](https://github.com/settings/tokens/new?description=guessingAverageWebHook&scopes=admin:repo_hook), it must have the scope "admin:repo_hook" and you must have admin rights on the repository
    + github_repository: The repository where the webhook will be created, it is already set to "guessingAverage"
    + github_repository_owner: The owner of the repository, it is already set to "StudyProjectsTHB"
    + docker_repository: The name of your Docker repository, it is already set to "leonxs/guessing_average:latest"
    + operation_system: Your operating system, it is already set to "windows" or "unix"

5. Install python dependencies
   ```shell
   pip install -r requirements.txt
   ```

6. Move into the terraform directory
   ```shell
   cd terraform
   ```

7. Initialize Terraform
   ```shell
   terraform init
   ```
8. Test your credentials
   ```shell
   terraform plan
   ```

9. Deploy the project
   ```shell
   terraform apply --auto-approve
   ```
    + The DNS name of the load balancer will be printed to the console. You can access the application via this URL.

10. Destroy the project
    ```shell
    terraform destroy --auto-approve
    ```
