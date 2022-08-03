variable "environment" {
  type        = string
  description = "Environment. Example: staging, production."
}
variable "domain_name" {
  type        = string
  description = "The root domain name."
}
variable "app_subdomain_name" {
  type        = string
  description = "The domain name for the public facing app. Application load balancer will be attached to this domain. Should be different for staging and production applications."
}
variable "alb_name" {
  type = string
  description = "Name of the application load balancer."
}
variable "alb_access_logs_prefix" {
  type        = string
  description = "S3 bucket prefix for application load balancer access logs."
}
variable "alb_access_logs_expiry_days" {
  type        = number
  description = "Number of days to retain application load balancer access logs."
}
variable "app_port" {
  type = number
  description = "The port number app is running on."
}
variable "alb_default_static_response" {
  type = object({
    content_type = string
    encoded_message_body = string
    status_code = string
  })
  description = "The default static response to return if no rules match in alb."
}
variable "vpc_id" {
  type = string
  description = "Identifier for AWS VPC where the resources will be created."
}
variable "http_https_ingress_sg_id" {
  type = string
  description = "Identifier for the security group allowing access to HTTP(80) and HTTPS(443) ingress. This is used for ingress traffic to load balancer."
}
variable "alb_subnets" {
  type = list(string)
  description = "List of subnet identifiers to associate subnets to load balancer."
}
variable "alb_aws_account_arn" {
  type = string
  description = "AWS account ARN for the account containing load balancer."
}
variable "alb_access_logs_bucket_name" {
  type = string
  description = "S3 bucket name which will be used to store load balancer access logs. Prefix <var.environment> will be added. The bucket name should be unique globally."
}
