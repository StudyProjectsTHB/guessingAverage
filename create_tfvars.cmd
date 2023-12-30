@echo off
setlocal

set "TerraformFolderPath=terraform"
set "FilePath=%TerraformFolderPath%\variables.auto.tfvars"

if exist "%FilePath%" (
    echo %FilePath% already exists.
) else (
    (
    echo aws_credentials = {
    echo   "aws_access_key_id": "YOUR_AWS_ACCESS_KEY_ID",
    echo   "aws_secret_access_key": "YOUR_AWS_SECRET_ACCESS_KEY",
    echo   "aws_session_token": "YOUR_AWS_SESSION_TOKEN",
    echo   "aws_db_password": "DB_PASSWORD",
    echo   "aws_db_user": "DB_USER",
    echo   "aws_ec2_public_key": "ssh-rsa YOUR_PUBLIC_KEY",
    echo }
    echo.
    echo github_credentials = {
    echo   "github_token": "YOUR_GITHUB_TOKEN",
    echo   "github_repository": "guessingAverage",
    echo   "github_repository_owner": "eineOrganisation",
    echo   "github_webhook_secret": "THE_SECRET_FOR_THE_WEBHOOK",
    echo }
    ) > "%FilePath%"

    echo created %FilePath%.
)

endlocal
