# 3-Tier Highly Available and Scalable AWS Architecture

This project provides a Terraform configuration for deploying a 3-tier, highly available, and scalable web application on AWS. The infrastructure is designed to be resilient, secure, and production-ready.

## Architecture Diagram

![AWS Architecture Diagram](Aws%20Architecture%20.png)

## Features

- **High Availability**: The architecture is distributed across multiple Availability Zones to ensure resilience against single AZ failures.
- **Scalability**: Auto Scaling Groups are used for both the web and application tiers, allowing the application to automatically scale in and out based on CPU load.
- **Security**: The application is deployed within a custom VPC with public and private subnets. Security Groups are used to control traffic between the different tiers and from the internet.
- **Three-Tier Architecture**:
    - **Web Tier**: A public-facing tier running NGINX, responsible for serving static content and routing API requests.
    - **Application Tier**: A private tier running a Node.js application, responsible for handling business logic.
    - **Data Tier**: (Not included in this configuration) A private tier for databases.
- **Infrastructure as Code**: The entire infrastructure is defined as code using Terraform, enabling versioning, reproducibility, and automation.

## Prerequisites

Before you begin, ensure you have the following installed:
- [Terraform](https://www.terraform.io/downloads.html) (v1.0 or later)
- An [AWS Account](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/) with the necessary permissions.
- AWS CLI configured with your credentials.

## Installation

1.  **Clone the repository:**
    ```sh
    git clone https://github.com/AhmedGaberElbltagy/Design-a-High-Available-and-Scalable-Architecture-on-AWS.git
    cd Design-a-High-Available-and-Scalable-Architecture-on-AWS
    ```

2.  **Initialize Terraform:**
    This command will download the necessary providers and initialize the backend.
    ```sh
    terraform init
    ```

## Usage

1.  **Plan the deployment:**
    This command will show you what resources will be created.
    ```sh
    terraform plan
    ```

2.  **Apply the configuration:**
    This command will create the infrastructure on AWS.
    ```sh
    terraform apply
    ```

3.  **Destroy the infrastructure:**
    When you are finished, you can destroy all the resources created.
    ```sh
    terraform destroy
    ```

## Terraform Modules

This project is organized into the following Terraform modules:

-   **`vpc`**: Creates the VPC, subnets (public and private), NAT Gateway, Internet Gateway, and route tables.
-   **`alb`**: Sets up the public-facing Application Load Balancer and an internal Application Load Balancer, along with their listeners and target groups.
-   **`ec2`**: Configures the Auto Scaling Groups and Launch Configurations for both the web and application tiers. It also includes the user data scripts for bootstrapping the instances. 

## Traffic Flow
### Step 1: DNS Lookup
A user types your website's address (e.g., www.your-app.com, which points to the ALB's DNS name) into their browser.
The browser performs a DNS lookup to translate this friendly domain name into the public IP address of your Public Application Load Balancer (ALB).
### Step 2: Request to the Public ALB
The user's request travels across the internet and enters your AWS VPC through the Internet Gateway.
The request arrives at the Public ALB. The ALB's listener, which is listening on port 80 (HTTP), accepts the request.
The ALB's Security Group (alb-sg) acts as the first firewall, ensuring the request is on a valid port (80 or 443).
### Step 3: Forwarding to the Web Tier
The Public ALB checks its rules. Since this is a request for the main page (e.g., path is /), the default rule matches.
The default rule is configured to forward traffic to the Web Tier Target Group (web-tg).
The ALB selects a healthy EC2 instance from the Web Tier Auto Scaling Group.
### Step 4: Web Server Processes the Request
The request arrives at an NGINX web server in a public subnet.
The Web Tier's Security Group (web-sg) acts as the second firewall, allowing the incoming traffic only from the Public ALB's security group.
The NGINX server finds the requested file (e.g., index.html) and prepares to send it back. 