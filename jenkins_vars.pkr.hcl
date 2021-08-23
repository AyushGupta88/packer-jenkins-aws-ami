variable "ami_prefix" {
  type    = string
  default = "jenkins-linux-aws"
}
variable "instance_type" {
  type    = string
  default = "t2.micro"
}
variable "region" {
  type    = string
  default = "us-east-1"
}
variable "source_ami" {
  type    = string
  default = "ami-09e67e426f25ce0d7"
}
variable "ssh_username" {
  type    = string
  default = "ubuntu"
}
