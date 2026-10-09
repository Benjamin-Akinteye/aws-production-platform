# Production-Style AWS Web Platform

A hands-on AWS infrastructure project demonstrating network segmentation, Infrastructure as Code, compute scaling, database isolation, and secure instance management using Terraform.

> **Project status:** Core infrastructure deployed and validated. CI/CD, automated security scanning, and expanded observability remain future milestones.

## Overview

This project builds a production-style web application foundation on AWS. Infrastructure is provisioned with Terraform, managed through Git and GitHub pull requests, and validated against the deployed AWS environment.

The lab demonstrates how to separate public entry points, private application workloads, and a private relational database while maintaining operational access to application instances through AWS Systems Manager (SSM).

The environment is deployed temporarily for testing and evidence collection. Resources will be destroyed after validation to control cloud costs.

## Architecture

**Request path**

Internet → Application Load Balancer → EC2 Auto Scaling application tier

**Database path**

EC2 application tier → private Amazon RDS for MySQL

**Management path**

Engineer → AWS Systems Manager → private EC2 instances

### AWS components

* **Amazon VPC:** `10.0.0.0/16`
* **Availability Zones:** `us-east-1a` and `us-east-1b`
* **Public subnets:** Internet-facing load balancer and NAT Gateway placement
* **Private application subnets:** EC2 instances managed by an Auto Scaling Group
* **Private database subnets:** RDS subnet group, without a direct internet route
* **Internet Gateway:** Public subnet connectivity
* **NAT Gateway:** Outbound internet access for private application instances
* **Application Load Balancer:** HTTP listener on port 80, forwarding to the application target group on port 8080
* **EC2 Auto Scaling Group:** Two desired instances, with a configured minimum and maximum of two
* **Amazon RDS for MySQL:** Private, encrypted, single-AZ database
* **AWS Systems Manager:** Remote management of EC2 instances without requiring public SSH access
* **AWS Secrets Manager:** Managed RDS master credentials
* **Terraform:** Infrastructure provisioning and drift/change review

See [`docs/architecture/architecture.md`](docs/architecture/architecture.md) for the detailed design.

## Network and security design

The VPC uses separate public, application, and database subnets across two Availability Zones.

Security groups control traffic between tiers:

* The ALB accepts HTTP and HTTPS traffic from the internet.
* The application tier accepts port 8080 traffic from the ALB security group.
* The database accepts MySQL traffic on port 3306 from the application security group.
* The database is not publicly accessible.
* EC2 metadata access requires IMDSv2.
* EC2 root EBS volumes are encrypted and use `gp3` storage.
* EC2 instance management uses an IAM role with the AWS-managed `AmazonSSMManagedInstanceCore` policy.

**Current lab limitations:** The ALB currently has an HTTP listener, not a configured HTTPS listener. The application tier uses a lightweight Python HTTP server for infrastructure testing. This is not a production application server. The database is single-AZ, and the lab uses one NAT Gateway to reduce costs.

## Validation performed

The deployed infrastructure has been checked using Terraform and AWS CLI commands.

* `terraform fmt` and `terraform validate` completed successfully.
* `terraform plan` reported no changes after deployment.
* The ALB returned HTTP 200 for the application endpoint.
* The `/health` endpoint returned HTTP 200.
* The Auto Scaling Group's rolling instance refresh completed successfully.
* The refreshed EC2 instances registered as `Online` in Systems Manager.
* A TCP connectivity test from EC2 to the private RDS endpoint on port 3306 succeeded.

The database connectivity test confirms network reachability only. MySQL authentication, SQL queries, and application-level database integration have not yet been demonstrated.

## Repository structure

```text
.
├── .github/
│   └── workflows/
├── docs/
│   ├── architecture/
│   ├── decisions/
│   ├── runbooks/
│   └── evidence/
├── terraform/
│   ├── modules/
│   └── environments/
│       └── dev/
├── scripts/
├── tests/
├── .gitattributes
├── .gitignore
└── README.md
```

## Engineering workflow

The project follows a feature-branch workflow:

1. Implement a focused infrastructure change.
2. Format and validate Terraform.
3. Review the execution plan before applying changes.
4. Deploy only to the personal lab AWS account.
5. Verify the resulting resources and behavior.
6. Commit changes and open a GitHub pull request.
7. Merge reviewed changes into `main`.
8. Record evidence and document design decisions.

The AWS account identity must be verified before making changes. This portfolio project must remain separate from any employer or startup AWS accounts.

## Cost management

This lab uses billable AWS services, including a NAT Gateway, Application Load Balancer, EC2 instances, and RDS.

The environment is temporary. Before teardown, verify the AWS account and Terraform working directory, review the destruction plan, and confirm that no required data or evidence remains only in AWS. The RDS configuration currently skips the final snapshot, so destroying the database can permanently delete its data.

## Planned improvements

* Configure HTTPS and certificate management for the ALB.
* Build an application that performs authenticated database queries.
* Add automated infrastructure security scanning.
* Add GitHub Actions CI with formatting, validation, and security checks.
* Add deployment automation using GitHub Actions OIDC and least-privilege IAM.
* Improve CloudWatch metrics, logs, alarms, and operational runbooks.
* Test failure scenarios and document recovery procedures.
* Review high-availability and cost-optimisation alternatives, including NAT Gateway design.
* Destroy temporary resources after collecting the required evidence.

## Learning outcomes

This project develops practical experience in Terraform-managed AWS networking, security-group design, EC2 Auto Scaling, private RDS deployment, SSM-based operations, infrastructure validation, Git collaboration, and cloud cost management.
