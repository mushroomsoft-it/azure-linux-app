terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.21.1"
    }
  }
}

provider "azurerm" {
  subscription_id            = var.subscription_id
  tenant_id                  = var.tenant_id
  client_id                  = var.client_id
  client_secret              = var.client_secret
  skip_provider_registration = true
  features {}
}
# Create a Resource Group if it doesn’t exist
resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = "${var.naming_prefix}-${var.environment}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.this.name
  sku                 = "PerGB2018"
  retention_in_days   = 730
}

resource "azurerm_application_insights" "this" {
  name                = "ai-${var.naming_prefix}-${var.environment}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.this.name
  workspace_id        = azurerm_log_analytics_workspace.this.id
  application_type    = "web"
}

resource "azurerm_service_plan" "this" {
  name                = "asp-${var.naming_prefix}-${var.environment}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.this.name
  os_type             = "Linux"
  sku_name            = var.web_tier
}


resource "azurerm_linux_web_app" "this" {
  name                = "web-${var.naming_prefix}-${var.environment}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.this.name
  service_plan_id     = azurerm_service_plan.this.id
  https_only          = "true"

  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.this.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.this.connection_string
    APPINSIGHTS_ROLENAME                  = "web-${var.naming_prefix}-${var.environment}"
    WEBSITE_ENABLE_SYNC_UPDATE_SITE       = "true"
    DOCKER_REGISTRY_SERVER_URL            = var.docker_registry_server_url
    DOCKER_REGISTRY_SERVER_USERNAME       = var.docker_registry_server_username
    DOCKER_REGISTRY_SERVER_PASSWORD       = var.docker_registry_server_password
  }

  site_config {
    always_on     = var.web_always_on
    ftps_state    = "Disabled"
    http2_enabled = true
    application_stack {
      docker_image     = var.docker_image
      docker_image_tag = var.docker_image_tag
    }
  }
}


locals {
  default_frontend_endpoint_name = "${var.naming_prefix}-${var.environment}-fd-azurefd-net"
  default_frontend_endpoint      = "${var.naming_prefix}-${var.environment}-fd.azurefd.net"
}

resource "azurerm_frontdoor" "this" {
  name                = "${var.naming_prefix}-${var.environment}-fd"
  friendly_name       = "${var.naming_prefix}-${var.environment}-fd"
  resource_group_name = data.azurerm_resource_group.starter.name

  frontend_endpoint {
    name      = local.default_frontend_endpoint_name
    host_name = local.default_frontend_endpoint
  }

  backend_pool {
    name = "${var.naming_prefix}-${var.environment}-backend-pool"
    backend {
      host_header = azurerm_linux_web_app.this.default_hostname
      address     = azurerm_linux_web_app.this.default_hostname
      http_port   = 80
      https_port  = 443
    }
    load_balancing_name = "load-balancing-${var.naming_prefix}-${var.environment}"
    health_probe_name   = "health-probe-${var.naming_prefix}-${var.environment}"
  }

  backend_pool_load_balancing {
    name = "load-balancing-${var.naming_prefix}-${var.environment}"
  }

  backend_pool_health_probe {
    name                = "health-probe-${var.naming_prefix}-${var.environment}"
    enabled             = false
    interval_in_seconds = 30
    probe_method        = "HEAD"
    protocol            = "Https"
  }

  # start: routes
  routing_rule {
    name               = "rule-${var.naming_prefix}-${var.environment}-all-paths"
    accepted_protocols = ["Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = [local.default_frontend_endpoint_name]
    forwarding_configuration {
      forwarding_protocol = "HttpsOnly"
      backend_pool_name   = "${var.naming_prefix}-${var.environment}-backend-pool"
    }
  }

  routing_rule {
    name               = "rule-${var.naming_prefix}-${var.environment}-http-to-https"
    accepted_protocols = ["Http"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = [local.default_frontend_endpoint_name]
    redirect_configuration {
      redirect_protocol = "HttpsOnly"
      redirect_type     = "Found"
    }
  }
  # end: routes
}
