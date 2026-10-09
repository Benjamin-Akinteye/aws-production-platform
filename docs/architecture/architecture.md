# AWS Web Platform Architecture

## 1. Purpose

This document describes the architecture currently implemented in the `aws-production-platform` Terraform project.

The goal is to demonstrate infrastructure engineering practices through a production-style lab, with clear separation of network tiers, controlled traffic flows, repeatable infrastructure changes, and verifiable operational behavior.

## 2. High-Level Architecture

```text
                           Internet
                              |
                       Internet Gateway
                              |
                 +-------------------------+
                 | Public Subnets          |
                 |                         |
                 | Application Load        |
                 | Balancer                |
                 |                         |
                 | NAT Gateway             |
                 +-------------------------+
                              |
                       ALB Listener :80
                              |
                    Target Group :8080
                              |
                 +-------------------------+
                 | Private App Subnets     |
                 |                         |
                 | EC2 Auto Scaling Group  |
                 | Desired capacity: 2     |
                 |                         |
                 | Python test application |
                 +-------------------------+
                              |
                       MySQL :3306
                              |
                 +-------------------------+
                 | Private DB Subnets      |
                 |                         |
                 | Amazon RDS for MySQL    |
                 | Single-AZ               |
                 +-------------------------+

Management:
Engineer --> AWS Systems Manager --> Private EC2 instances
```

## 3. Region and Network

* **AWS region:** `us-east-1`
* **VPC CIDR:** `10.0.0.0/16`
* **Availability Zones:** `us-east-1a`, `us-east-1b`

### Subnet allocation

| Tier        | Availability Zone | CIDR           |
| ----------- | ----------------- | -------------- |
| Public      | `us-east-1a`      | `10.0.1.0/24`  |
| Public      | `us-east-1b`      | `10.0.2.0/24`  |
| Application | `us-east-1a`      | `10.0.11.0/24` |
| Application | `us-east-1b`      | `10.0.12.0/24` |
| Database    | `us-east-1a`      | `10.0.21.0/24` |
| Database    | `us-east-1b`      | `10.0.22.0/24` |

Public subnets route internet-bound traffic through the Internet Gateway. Private application subnets use a NAT Gateway for outbound internet access. Database subnets have no default internet route.

The NAT Gateway is placed in a public subnet and serves both application subnets. This is a cost-conscious lab design and introduces a shared dependency and Availability Zone failure consideration. A production design should evaluate per-AZ NAT gateways and other appropriate egress options against resilience requirements and cost.

## 4. Traffic Flow

### Inbound application traffic

1. A client sends an HTTP request to the ALB.
2. The ALB listener on port 80 forwards requests to the application target group on port 8080.
3. The target group routes requests to healthy EC2 instances.
4. The application responds to the request.

The test application responds to `/health` with HTTP 200 and `healthy`. The application is a lightweight Python HTTP server intended to validate infrastructure behavior, not a production web workload.

**Current limitation:** An HTTPS listener and TLS certificate have not yet been configured.

### Database traffic

1. An application-tier instance initiates a connection to the private RDS endpoint on TCP port 3306.
2. The database security group allows MySQL traffic from the application security group.
3. The connection is routed within the VPC to the RDS instance.

A successful TCP connectivity test confirms that the network path is available. It does not establish that the database credentials work or that the application can execute SQL queries.

### Management traffic

EC2 instances use an IAM instance profile with the `AmazonSSMManagedInstanceCore` managed policy. The SSM agent registers the instances with Systems Manager, allowing administrative sessions and commands without opening inbound SSH access to the internet.

The private application subnets currently rely on NAT Gateway egress to reach public AWS service endpoints where needed.

## 5. Security Controls

### Network segmentation

* Public resources are separated from application and database workloads.
* Application instances are deployed in private subnets.
* RDS is configured with `publicly_accessible = false`.
* Database traffic is restricted to the application security group.
* The application security group permits application traffic from the ALB security group on port 8080.

### Compute hardening

* EC2 uses Amazon Linux 2023.
* IMDSv2 is required.
* The root EBS volume uses encrypted `gp3` storage.
* Root storage is configured to be deleted with the instance.

### Identity and secrets

* EC2 uses an instance role for Systems Manager.
* RDS master credentials are managed by AWS Secrets Manager.
* Database credentials are not hardcoded in the Terraform configuration.

The current SSM role is intended for instance management. The test application has not been granted database-secret access because application-level database integration has not been implemented.

## 6. Availability and Scaling

The VPC has subnets in two Availability Zones, and the EC2 Auto Scaling Group is configured with a desired, minimum, and maximum capacity of two instances.

The ALB target group uses `/health` for health checks. The Auto Scaling Group uses ELB health checks and has an instance-refresh configuration.

A controlled rolling instance refresh was performed after updating the launch template to attach the SSM instance profile. The refresh completed successfully, and the replacement targets became healthy.

**Availability limitations:**

* The RDS instance is single-AZ.
* One NAT Gateway serves both application subnets.
* The ALB listener currently uses HTTP.
* The test application is not configured as a supervised production service.

These limitations are documented deliberately rather than presenting the lab as fully production-ready.

## 7. Database Design

* **Engine:** MySQL
* **Instance class:** `db.t3.micro`
* **Allocated storage:** 20 GiB
* **Storage type:** `gp3`
* **Encryption:** Enabled
* **Public access:** Disabled
* **Availability:** Single-AZ
* **Backup retention:** One day
* **Master credentials:** Managed by AWS Secrets Manager

Deletion protection is disabled and final snapshot creation is skipped to simplify teardown of this temporary lab. These are cost and lifecycle choices for the lab, not general production recommendations. Destroying the database can permanently remove its data.

## 8. Infrastructure as Code

Terraform defines the VPC, subnets, route tables, security groups, ALB, target group, launch template, Auto Scaling Group, IAM resources, and RDS database.

The engineering workflow uses feature branches and pull requests. Before applying infrastructure changes, the workflow includes:

* `terraform fmt`
* `terraform validate`
* `terraform plan`
* Review of proposed additions, modifications, and deletions
* Verification of the AWS account identity

A clean plan was obtained after the RDS and SSM implementation was deployed.

## 9. Verified Tests

| Test                           | Result                |
| ------------------------------ | --------------------- |
| Terraform formatting           | Passed                |
| Terraform validation           | Passed                |
| Final Terraform plan           | No changes            |
| ALB application endpoint       | HTTP 200              |
| Application `/health` endpoint | HTTP 200              |
| Auto Scaling instance refresh  | Successful            |
| SSM instance registration      | Both instances online |
| EC2-to-RDS TCP connectivity    | Successful            |

Evidence screenshots should be stored in `docs/evidence/` and should not contain passwords, secret values, access keys, or other sensitive information.

## 10. Cost and Lifecycle

This is a temporary portfolio lab in a personal AWS account. The NAT Gateway, ALB, EC2 instances, and RDS database can incur ongoing charges.

After validation and evidence collection, infrastructure should be destroyed using Terraform from the correct environment directory and after confirming the AWS account. Review the destroy plan carefully before approving it.

## 11. Future Improvements

* Add HTTPS and TLS certificate management.
* Implement a real application with authenticated database queries.
* Add CI validation and security scanning.
* Implement GitHub Actions OIDC for deployment automation.
* Expand monitoring, alarms, and operational runbooks.
* Test application and infrastructure failure scenarios.
* Evaluate more resilient egress and database availability designs.
* Document recovery and restore procedures.
