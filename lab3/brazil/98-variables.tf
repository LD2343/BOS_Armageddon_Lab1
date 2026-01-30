variable "aws_account_id" {
  description = "id of aws account"
  type        = string
  default     = "891377135193"
}

variable "aws_region" {
  description = "AWS Region for the gro fleet to patrol."
  type        = string
  default     = "sa-east-1"
}

variable "project_name" {
  description = "Prefix for naming. Students should change from 'gro' to their own."
  type        = string
  default     = "gro"
}

variable "vpc_cidr" {
  description = "VPC CIDR (use 10.x.x.x/xx as instructed)."
  type        = string
  default     = "10.55.0.0/16" # TODO: student supplies
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs (use 10.x.x.x/xx)."
  type        = list(string)
  default     = ["10.55.1.0/24", "10.55.2.0/24"] # TODO: student supplies
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs (use 10.x.x.x/xx)."
  type        = list(string)
  default     = ["10.55.101.0/24", "10.55.102.0/24"] # TODO: student supplies
}

variable "azs" {
  description = "Availability Zones list (match count with subnets)."
  type        = list(string)
  default     = ["sa-east-1a", "sa-east-1b", "sa-east-1c"] # TODO: student supplies
}

variable "ec2_ami_id" {
  description = "AMI ID for the EC2 app host."
  type        = string
  default     = "ami-0f85876b1aff99dde" # TODO
}

variable "ec2_instance_type" {
  description = "EC2 instance size for the app."
  type        = string
  default     = "t3.micro"
}


variable "sns_email_endpoint" {
  description = "Email for SNS subscription (PagerDuty simulation)."
  type        = string
  default     = "larrygharris76@gmail.com" # TODO: student supplies
}


variable "enable_waf" {
  description = "Toggle WAF creation."
  type        = bool
  default     = true
}

variable "alb_5xx_threshold" {
  description = "Alarm threshold for ALB 5xx count."
  type        = number
  default     = 10
}

variable "alb_5xx_period_seconds" {
  description = "CloudWatch alarm period."
  type        = number
  default     = 300
}

variable "alb_5xx_evaluation_periods" {
  description = "Evaluation periods for alarm."
  type        = number
  default     = 1
}

variable "enable_alb_access_logs" {
  description = "Whether to create the S3 bucket for ALB access logs"
  type        = bool
  default     = true # ← choose your preferred default
}


variable "alb_access_logs_prefix" {
  type    = string
  default = "alb-access-logs"

  validation {
    condition     = !can(regex("(?i)AWSLogs", var.alb_access_logs_prefix))
    error_message = "alb_access_logs_prefix must NOT contain 'AWSLogs' (case-insensitive) — AWS adds this automatically."
  }
}



variable "peer_transit_gateway_id" {
  description = "ID of the Shinjuku Transit Gateway in ap-northeast-1 (Japan TGW ID)"
  type        = string
  default     = ""   # ← Japan's TGW ID (you can keep or update)
}

variable "peer_region" {
  description = "AWS region of the peer Transit Gateway"
  type        = string
  default     = "ap-northeast-1"
}

variable "enable_tgw_peering" {
  description = "Whether to accept the Transit Gateway peering attachment from Japan"
  type        = bool
  default     = false   # ← change to true AFTER Japan creates the peering request
}

variable "waf_log_destination" {
  description = "Where to send AWS WAFv2 logs: 'cloudwatch', 'firehose', 's3', or 'none'"
  type        = string
  default     = "cloudwatch" # or "cloudwatch" if you want it on by default
  validation {
    condition     = contains(["cloudwatch", "firehose", "s3", "none"], var.waf_log_destination)
    error_message = "Valid values are: cloudwatch, firehose, s3, none."
  }
}