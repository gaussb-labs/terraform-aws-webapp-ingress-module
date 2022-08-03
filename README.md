### Webapp Ingress Terraform Module

This module provides setup of the AWS resources needed for web traffic ingress.
The module takes care of the following aspects:
- Using existing Route53 hosted zone
- Setting up SSL certificate for the application sub-domain specified with automatic verification
- Setting up application load balancer, target group and attaching the SSL certificate to the load balancer
- Setting up S3 bucket for storing load balancer access logs
- Setting up the retention policy for the access logs
