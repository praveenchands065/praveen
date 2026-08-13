# 2-tier Architecture for AWS by using Terraform
AWS 2-Tier Architecture using Terraform

📌 Overview

This project demonstrates the design and deployment of a 2-Tier Architecture on AWS using Terraform (Infrastructure as Code).

The architecture separates the application and database layers to provide better security, scalability, and maintainability.

🏗️ Architecture

Users → Internet Gateway → EC2 (Application Tier) → RDS (Database Tier)

Application Tier

- Amazon EC2
- Public/Private Subnets
- Security Groups

Database Tier

- Amazon RDS
- Private Subnet
- Restricted database access

Networking

- Amazon VPC
- Internet Gateway
- NAT Gateway
- Public & Private Subnets
- Route Tables
- Security Groups

🛠️ Technologies Used

- AWS
- Terraform
- Amazon VPC
- Amazon EC2
- Amazon RDS
- Internet Gateway
- NAT Gateway
- Security Groups
- Linux

📂 Project Structure

2-tier-architecture/
├── main.tf
├── variables.tf
├── outputs.tf
├── provider.tf
├── security-groups.tf
├── vpc.tf
├── subnet.tf
├── route-table.tf
├── ec2.tf
├── rds.tf
└── README.md

🚀 Deployment

1. Clone the repository

git clone <your-repository-url>
cd 2-tier-architecture

2. Initialize Terraform

terraform init

3. Validate the configuration

terraform validate

4. Review the infrastructure

terraform plan

5. Deploy the infrastructure

terraform apply

🔐 Security

The architecture follows basic AWS security best practices:

- Database resources are placed in private subnets.
- RDS access is restricted through security groups.
- Application and database tiers use separate security rules.
- Network traffic is controlled using route tables and security groups.
- Sensitive credentials should not be hardcoded in Terraform files.

🎯 Key Learning Outcomes

- Designing AWS 2-tier architecture
- Creating AWS infrastructure using Terraform
- Understanding VPC networking
- Working with public and private subnets
- Configuring EC2 and RDS
- Implementing security groups
- Managing infrastructure through Infrastructure as Code

👨‍💻 Author

Praveen Chandra

DevOps & Cloud Engineer | AWS | Azure | Terraform | Docker | Kubernetes | Jenkins
