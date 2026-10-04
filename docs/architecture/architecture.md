# Architecture

## Overview

This project implements a production-style web application platform on AWS.

The architecture separates internet-facing resources from application and database resources.

## High-Level Architecture

Internet
    |
    v
Application Load Balancer
    |
    v
Application Tier
    |
    v
Database Tier

## Network Design

The AWS VPC will contain:

- Public subnets
- Private application subnets
- Private database subnets

## Design Principles

- Least privilege
- Network segmentation
- High availability
- Infrastructure as Code
- Automated deployment
- Observability
- Security