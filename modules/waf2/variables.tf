variable "tags" {
  type = map(string)
}
variable "waf_prefix" {
  type = string
}
variable "waf_ip_sets" {
  type = list(string)
  default = ["0.0.0.0/1", "128.0.0.0/1"] // allow all
}
variable "scope" {
  type = string
}
variable "enableBlock" {
  type = bool
}