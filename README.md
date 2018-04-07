# Intro to Terraform

[![Terraform](https://img.shields.io/badge/terraform-0.11.x-brightgreen.svg)](http://terraform.io)

Infrastructure is deployed using Terraform to configure and maintain Infrastructure concerns as code.

## Getting started
After cloning this repo to your local machine you will need to do the following to be ready to use these Terrafrom Infrastructure as Code (IaC) script.

1. A Terraform installation is required and should be version 0.11.x. This is available from [Download Terraform](https://www.terraform.io/downloads.html)
2. An IAM user account will need to be available with valid AWS access key and secret access key.
3. Run this command to set the AWS access key and secret access key.

```
export AWS_ACCESS_KEY_ID=<<AWS_ACCESS_KEY_ID>>
export AWS_SECRET_ACCESS_KEY=<<AWS_SECRET_ACCESS_KEY>>
```

## Creating the infrastructure
To create the cluster, use terraform as below:

```
terraform init
terraform plan
terraform plan -var server_port="8080"
```
This ouputs:

```
Outputs:
elb_dns_name = <elb_dns_name>
```

## Accessing the web server

```
curl http://<elb_dns_name>
```

### Success!

## Manage Terrafom state files in S3
You need to create a bucket in S# before using this command
```
terraform remote config \
    -backend=s3 \
    -backend-config="bucket=(YOUR_BUCKET_NAME)" \
    -backend-config="key=terraform.tfstate" \
    -backend-config="region=(YOUR_BUCKET_REGION)" \
    -backend-config="encrypt=true"
```

## Clean up
```terraform destroy
Do you really want to destroy?
  Terraform will delete all your managed infrastructure.
  There is no undo. Only 'yes' will be accepted to confirm.
Enter a value:
```
Type in “yes” and hit enter