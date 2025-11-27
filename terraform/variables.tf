variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of existing EC2 Key Pair in AWS (not the .pem filename)."
  type        = string
  default     = "check"
}

variable "repo_url" {
  description = "HTTPS clone URL of your forked Jarvis repo"
  type        = string
  default     = "https://github.com/YOUR_USERNAME/Jarvis-Desktop-Voice-Assistant.git"
}

variable "owner_user" {
  description = "System user to run app"
  type        = string
  default     = "ubuntu"
}
