variable "cidr" {
  default = "10.0.0.0/16"
}

variable "ami_serv" {
  default = "ami-0261755bbcb8c4a84"
}
variable "instance" {
  default = "t2.micro"
  
}

variable "pk_path" {
  default = "~/.ssh/id_rsa.pub"
}

variable "privk_path" {
  default = "~/.ssh/id_rsa"
}


variable "ssh_user" { #based on your ami - machine OS
  default = "ubuntu"
}
