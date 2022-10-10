variable "subscription_id" {
  type        = string
  description = "The Azure subscription to deploy these resources to"
}

variable "tenant_id" {
  type        = string
  description = "The Azure tenant where the resources are deployed to"
}

variable "resource_group_name" {
  type        = string
  description = "The Azure resource group the resources are deployed to"
}

variable "client_id" {
  type        = string
  description = "The AD service principal to use to deploy the resources"
}

variable "client_secret" {
  type        = string
  description = "The AD service principal secret"
}

variable "environment" {
  type        = string
  description = "solution environment where the resource will be used for. (dev, ci, uat, prod..)"
  default     = "ci"
}

variable "location" {
  type        = string
  description = "The default Azure region to deploy to"
  default     = "eastus2"
}

variable "naming_prefix" {
  type        = string
  description = "Prefix used when generating resource names"
  default     = "mushroomsoft"
}

variable "web_always_on" {
  type        = string
  description = "Whether the Web App will be always on"
  default     = "false"
}

variable "web_tier" {
  type        = string
  description = "VM tier for the Web App plan"
  default     = "B1"
}
# docker 
variable "docker_registry_server_url" {
  type        = string
  description = "Docker Registry Url for downloading the image"

}

variable "docker_registry_server_username" {
  type        = string
  description = "Docker Registry Username for downloading the image"
 
}


variable "docker_registry_server_password" {
  type        = string
  description = "Docker Registry Password for downloading the image"
  
}

variable "docker_image" {
  type        = string
  description = "Docker Image to use"

}

variable "docker_image_tag" {
  type        = string
  description = "Docker Image tag"
  default     = "latest"

}

