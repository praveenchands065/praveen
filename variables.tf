variable "ami_id" {
    type = string
    default = "ami-08982f1c5bf93d976"
    description = "EC2 ami id"
}

variable "instance_type" {
    type = string
    default = "t3.micro"
    description = "EC2 instance type"
}

variable "ami_id_2" {
    type = string
    default = "ami-08982f1c5bf93d976"
    description = "EC2 ami id 2"
}

variable "instance_type_2" {
    type  = string
    default = "t3.micro"
    description = "EC2 instance type"
}