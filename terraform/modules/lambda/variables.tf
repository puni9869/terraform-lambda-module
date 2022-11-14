# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "function_name" {
  type        = string
  description = "A unique name for your Lambda Function."
}

variable "handler" {
  type        = string
  description = "The function entrypoint in your code."
}

variable "role_arn" {
  type = string
}

variable "filename" {
  type        = string
  description = "The path to the function's deployment package within the local filesystem. If defined, The s3_-prefixed options cannot be used."
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------
variable "description" {
  type        = string
  default     = ""
  description = "Description of what your Lambda Function does."
}

variable "tags" {
  type    = map(string)
  default = {
    Terraform = "managed"
  }
  description = "A mapping of tags to assign to the Lambda function."
}

variable "security_group_id" {
  type        = list(string)
  default     = []
  description = "Provide this to allow your function to access your VPC (if both 'subnet_ids' and 'security_group_ids' are empty then vpc_config is considered to be empty or unset, see https://docs.aws.amazon.com/lambda/latest/dg/vpc.html for details)."
}

variable "subnet_ids" {
  type        = list(string)
  default     = []
  description = "Provide this to allow your function to access your VPC (if both 'subnet_ids' and 'security_group_ids' are empty then vpc_config is considered to be empty or unset, see https://docs.aws.amazon.com/lambda/latest/dg/vpc.html for details)."
}
variable "environment" {
  description = "Environment (e.g. env variables) configuration for the Lambda function enable you to dynamically pass settings to your function code and libraries"
  default     = null
  type        = object({
    variables = map(string)
  })
}

variable "vpc_config" {
  description = "Provide this to allow your function to access your VPC (if both 'subnet_ids' and 'security_group_ids' are empty then vpc_config is considered to be empty or unset, see https://docs.aws.amazon.com/lambda/latest/dg/vpc.html for details)."
  type        = map(list(string))
  default     = {
    "security_group_ids" : [],
    "subnet_ids" : []
  }
}

