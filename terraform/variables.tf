# variable "subnet_ids" {
#   type = list(string)
# }

# variable "region" {
#   type    = string
#   default = "eu-north-1"

# }

# New appraoch 

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the EKS cluster"
  default     = [] # Adding a default value prevents the 'Required' error
}

variable "region" {
  type    = string
  default = "eu-north-1"
}

# Add this block so Terraform accepts the -var="cluster_name=..." from Jenkins
variable "cluster_name" {
  type    = string
  default = "demo-eks"
}
