# ADR-001: Infrastructure Architecture

## Status

Accepted

## Context

The project requires a highly available AWS web application platform that demonstrates production-oriented cloud and DevOps engineering practices.

The infrastructure must provide:

- Network segmentation
- Application availability
- Secure database connectivity
- Infrastructure as Code
- Scalability
- Observability

The infrastructure will only be deployed temporarily for validation and portfolio evidence.

## Decision

The platform will use a multi-tier AWS architecture consisting of:

- VPC
- Public subnets
- Private application subnets
- Private database subnets
- Application Load Balancer
- EC2 Auto Scaling
- RDS
- CloudWatch
- Terraform

The application tier will not be directly exposed to the internet.

The database tier will only accept traffic from the application tier.

## Alternatives Considered

### Single EC2 Instance

Rejected because it does not demonstrate high availability or load balancing.

### Public Application Instances

Rejected because application servers should not need to be directly accessible from the internet.

### Database in a Public Subnet

Rejected because the database should not be directly exposed to the internet.

## Consequences

### Positive

- Better network isolation
- Improved availability
- Scalable application tier
- Clear security boundaries
- Demonstrates production-oriented architecture

### Negative

- Increased infrastructure complexity
- Higher temporary AWS cost
- Additional networking components are required
- NAT Gateway and load balancer costs must be carefully controlled

## Cost Control

Infrastructure will be destroyed after testing and evidence collection.

No long-running production workload will be maintained in this portfolio environment.