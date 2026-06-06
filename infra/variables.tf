variable "location" {
  type        = string
  description = "Resource location for Azure resources"
}

variable "project" {
  type        = string
  description = "Project short name."
}

variable "tags" {
  type        = map(string)
  description = "Azure tags."
}

variable "environment" {
  type        = string
  description = "Name of Azure environment."
}

variable "db_user" {
  type        = string
  description = "PostgreSQL administrator username."
  default     = "alanabarrettfrew"
}

variable "db_password" {
  type        = string
  description = "PostgreSQL administrator password."
  sensitive   = true
}
