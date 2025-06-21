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