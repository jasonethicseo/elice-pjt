###Comm###
variable "region" {
  type = string
}
variable "stage"{
  type = string
}
variable "servicename"{
  type = string
}
variable "tags" {
  type =map(string)
}

###Network###
variable "subnet_ids" {
  type = list(any)
}
variable "sg_eks_cluster_ingress_list" {
  type = list(any)
}
variable "network_vpc_id" {
  type = string
}
variable "service_ipv4_cidr" {
  type    = string
  default = "172.16.0.0/12"
}

###EKS###
variable "eks_kms_key_id" {
  type = string
}
variable "desired_size" {
  type = string
  default  = 2
}
variable "max_size" {
  type = string
  default = 2
}
variable "min_size"{
  type = string
  default = 1
}
variable "max_unavailable" {
  type = string
  default = 1
}
variable "ami_type" {
  type = string
  default = "AL2_x86_64" #AL2_ARM_64
}
variable "ami_is_eks_optimized"{
  type = bool
  default = true
}
variable "capacity_type" {
  type = string
  default = "ON_DEMAND"
}
variable "disk_size"{
  type = string
  default = "20"
}
variable "force_update_version" {
  type = bool
  default = true
}
variable "instance_types" {
  type = list
  default  = ["t3.xlarge"]
}
variable "labels" {
  type = map(string)
  default = {}
}

variable "disk_kms_key_id"{
  type = string
}
variable "s3_kms_key_id"{
  type = string
}
variable "rds_data_kms_arn"{
  type = string
}
variable "sqs_kms_arn"{
  type = string
}

variable "smoke_test_repository_arn"{
  type = string
}

###NodeGroup###

#variable "namespace" {
#  type = list(any)
#}
#variable "security_account" {
#  type = string
#}
#variable "cargo_secret_name" {
#  type = string
#}
#variable "kld_secret_name" {
#  type = string
#}
#variable "kms_secret_key" {
#  type = string
#}
#
variable "sg_allow_comm_ing" {
  type = list
}

variable "enable_cluster_autoscaler" {
  description = "Enable cluster autoscaler"
  type        = bool
  default     = false
}
