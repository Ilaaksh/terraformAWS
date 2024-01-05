# Terraform AWS Infrastructure - Deploying a Web Server
## This project uses Terraform to deploy basic infrastructure on AWS for deploying a Web Server:

### Resources Created
* VPC
* Internet Gateway
* Custom Route Table
* Public Subnet
* Route Table Association
* Security Group for Web Traffic
* Network Interface
* Elastic IP
* EC2 Instance running Apache Web Server

### Usage
### 1. Configure your AWS credentials in the provider block

### 2. Initialize Terraform
`terraform init`

### 3.Review the changes Terraform will make
`terraform plan`

### 4.Format the Terraform code
`terraform fmt`

### 5.Apply code
`terraform apply`

