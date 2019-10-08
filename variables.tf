variable "region" {
  description = "The name of the region."
  type        = "string"
}

variable "lambda_function_name" {
  description = "The name of the lambda fuction."
  default     = "terraformcreatedlambdafunction"
  type        = "string"
}

variable "lambda_handler" {
  description = "The name of the lambda fuction handler."
  default     = "lambda_handler"
  type        = "string"
}

variable "demo" {
  description = "The env variable for lambda."
  default     = "1234"
  type        = "string"
}
