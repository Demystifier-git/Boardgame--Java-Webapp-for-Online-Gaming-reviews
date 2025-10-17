variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Full cluster name (must match your DNS zone)"
  type        = string
  default     = "cluster.delightdavid.online"
}

variable "kops_state_bucket" {
  description = "S3 bucket for Kops state (must be globally unique)"
  type        = string
  default     = "boardgame-app-2028"
}

variable "zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.31.0"
}

variable "node_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}

variable "node_size" {
  description = "Instance type for worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "master_size" {
  description = "Instance type for master nodes"
  type        = string
  default     = "t3.medium"
}

variable "ssh_public_key_path" {
  description = "Path to public SSH key"
  type        = string
  default     = "bastion-key.pem.pub"
}

variable "my_ip" {
  description = "Your IP address or CIDR for SSH/API access"
  type        = string
  default     = "105.112.67.184/32" # ⚠️ Change this to your IP, e.g. "102.89.45.12/32"
}

variable "additional_kops_create_args" {
  description = "Additional kops flags"
  type        = string
  default     = "--topology public --networking calico"
}
