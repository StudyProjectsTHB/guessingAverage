@echo off
setlocal

set "TerraformFolderPath=terraform"
set "FilePath=%TerraformFolderPath%\variables.auto.tfvars"

if exist "%FilePath%" (
    echo %FilePath% already exists.
) else (
    (
    echo aws_credentials = {
    echo   "access_key": "YOUR_AWS_ACCESS_KEY_ID",
    echo   "secret_key": "YOUR_AWS_SECRET_ACCESS_KEY",
    echo   "token": "YOUR_AWS_SESSION_TOKEN",
    echo   "db_password": "DB_PASSWORD",
    echo   "db_user": "DB_USER",
    echo   "public_key": "ssh-rsa YOUR_PUBLIC_KEY",
    echo }
    echo.
    echo github_credentials = {
    echo   "token": "YOUR_GITHUB_TOKEN",
    echo   "repository": "guessingAverage",
    echo   "owner": "eineOrganisation",
    echo }
    ) > "%FilePath%"

    echo created %FilePath%.
)

endlocal
