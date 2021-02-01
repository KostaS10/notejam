# Authenticating SP

variable "subscription_id" {
  type = string
}
variable "client_id" {
  type = string
}
variable "client_secret" {
  type = string
}
variable "tenant_id" {
  type = string
}

# Resource deployment

variable "rg" {
  type    = string
  default = "nordcloud_assignment"
}
variable "location" {
  type    = string
  default = "westeurope"
}

variable "rg2" {
	type = string
	default = "nordcloud_assignment2"
}

variable "location2" {
	type = string
	default = "northeurope"
}

variable "adminpass" {
	type = string
}
