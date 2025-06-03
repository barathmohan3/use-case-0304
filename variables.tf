variable "instance_type" {

  description = "Instance type for EC2"

  type        = string

  default     = "t2.micro"

}

variable "tags" {

  description = "Tags to be applied to resources"

  type        = map(string)

  default = {

    Environment = "Dev"

    Project     = "OpenProject + DevLake"

    Owner       = "YourName"

    Name        = "Infra" # This gets prefixed in ec2 module for instance names

  }

}
 