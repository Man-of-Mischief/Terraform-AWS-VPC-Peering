########### Variables.tf

variable "ami" {
  description = "ami id"
  type        = string
  default     = "ami-08333bccc35d71140"
}

variable "type" {
  description = "instance type"
  type        = string
  default     = "t2.micro"
}

variable "project" {
  description = "project tag value"
  type        = string
  default     = "zomato"
}

variable "env" {
  description = "env tag value"
  type        = string
  default     = "dev"
}

variable "access_key" {
  default = "abcd"
}

variable "secret_key" {
  default = "efgh/ijkl"
}

variable "az" {
  default = "us-east-2"
}

variable "vpcidr" {
  default = "10.1.0.0/16"
}

variable "domain"{
	default = "abcd.co.in"
}
