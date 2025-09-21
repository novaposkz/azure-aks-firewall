# ========================================================================
# TERRAFORM AND PROVIDER VERSION CONSTRAINTS
# ========================================================================
# This file defines the required versions for Terraform and providers
# to ensure compatibility and reproducible deployments
# ========================================================================

terraform {
  # ========================================================================
  # TERRAFORM VERSION REQUIREMENTS
  # ========================================================================
  # Minimum Terraform version required for this configuration
  required_version = ">= 1.6.0"

  # ========================================================================
  # REQUIRED PROVIDERS CONFIGURATION
  # ========================================================================
  required_providers {
    # Azure Resource Manager Provider
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.115.0"  # More specific version constraint for stability
    }

    # Random provider for generating unique values
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }

    # Time provider for time-based resources
    time = {
      source  = "hashicorp/time"
      version = "~> 0.12.0"
    }
  }

  # ========================================================================
  # TERRAFORM BACKEND CONFIGURATION (OPTIONAL)
  # ========================================================================
  # Uncomment and configure if using remote state storage
  # backend "azurerm" {
  #   resource_group_name  = "terraform-state-rg"
  #   storage_account_name = "terraformstateaccount"
  #   container_name       = "tfstate"
  #   key                  = "azure-firewall-security.terraform.tfstate"
  # }
}

# ========================================================================
# AZURE RESOURCE MANAGER PROVIDER CONFIGURATION
# ========================================================================
provider "azurerm" {
  # Enable all features for comprehensive resource management
  features {
    # Key Vault features
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }

    # Resource Group features
    resource_group {
      prevent_deletion_if_contains_resources = false
    }

    # Virtual Machine features
    virtual_machine {
      delete_os_disk_on_deletion     = true
      graceful_shutdown             = false
      skip_shutdown_and_force_delete = false
    }

    # Log Analytics Workspace features
    log_analytics_workspace {
      permanently_delete_on_destroy = true
    }
  }

  # Skip provider registration for faster deployment (optional)
  skip_provider_registration = false
}

# ========================================================================
# RANDOM PROVIDER CONFIGURATION
# ========================================================================
provider "random" {
  # No specific configuration required
}

# ========================================================================
# TIME PROVIDER CONFIGURATION
# ========================================================================
provider "time" {
  # No specific configuration required
}