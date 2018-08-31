variable "count" {
    default = 2
  }
variable "region" {
  description = "AWS region for hosting our your network"
  default = "us-east-2"
}
variable "public_key_path" {
  description = "Enter the path to the SSH Public Key to add to AWS."
  default = "C:\\test2\\public.pub"
}
variable "key_name" {
  description = "MySSHKey"
  default = "deployer-key1"
}
variable "amis" {
  description = "Base AMI to launch the instances"
  default = {
  us-east-2 = "ami-0552e3455b9bc8d50"
  }
}