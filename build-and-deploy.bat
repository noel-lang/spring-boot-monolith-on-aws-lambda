@echo off
set "template_file=template.yaml"
set "repo_name=spring-boot-test"
set "region=eu-central-1"

if "%~1"=="" (
    echo Usage: build_and_deploy.bat YOUR_AWS_ACCOUNT_ID
    exit /B 1
)

set "account_id=%~1"

if not defined account_id (
    echo "account_id is a required parameter."
    exit /B 1
)

set "ecr_uri=%account_id%.dkr.ecr.%region%.amazonaws.com/%repo_name%"

rem Build application
call ./gradlew clean build

rem Build Docker image
call docker build -t %ecr_uri%:latest . --build-arg SAM_CLI_VERSION=1.80.0 --build-arg AWS_CLI_ARCH=aarch64

rem Push docker image
call docker push %ecr_uri%:latest

rem Get latest image details from ECR
for /f "tokens=*" %%a in ('aws ecr describe-images --repository-name %repo_name% --region %region% --query "sort_by(imageDetails,& imagePushedAt)[-1].[imageDigest]" --output=text') do set latest_sha=%%a

rem Update the template file with the latest image sha
set "image_uri=%ecr_uri%@%latest_sha%"
powershell -Command "(gc %template_file%) -replace 'ImageUri: .+', 'ImageUri: %image_uri%' | Set-Content %template_file%"

rem Update the template file with the current timestamp
for /f %%a in ('wmic os get LocalDateTime ^| findstr /b /c:"20"') do set current_timestamp=%%a
set current_timestamp=%current_timestamp:~0,4%-%current_timestamp:~4,2%-%current_timestamp:~6,2%T%current_timestamp:~8,2%:%current_timestamp:~10,2%:%current_timestamp:~12,2%Z
powershell -Command "(gc %template_file%) -replace 'DeployTimestamp: .*', 'DeployTimestamp: "%current_timestamp%"' | Set-Content %template_file%"

rem Package application
call sam build

rem Deploy application
call sam deploy
