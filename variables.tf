# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  type        = string
  default     = "LAB"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  type        = string
  default     = "West Europe"
}

variable "subscription_id" {
  description = "Azure Subscription Id"
  type        = string
  sensitive   = true
  default     = ""
}

variable "tenant_id" {
  description = "Azure Tenant Id"
  type        = string
  sensitive   = true
  default     = ""
}

variable "client_id" {
  description = "Azure Client Id"
  type        = string
  sensitive   = "true"
  default     = ""
}

variable "client_secret" {
  description = " Enter Azure Client Secret"
  type        = string
  sensitive   = "true"
}

variable "adminuser" {
  description = "Enter password for admin user"
  type        = string
  sensitive   = "true"
}
