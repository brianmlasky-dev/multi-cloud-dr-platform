terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # Remote state stored in GCS (exam topic: backends)
  backend "gcs" {
    bucket = "multi-cloud-dr-terraform-state"
    prefix = "gcp/terraform.tfstate"
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region

  default_labels = {
    project     = "multi-cloud-dr-platform"
    environment = var.environment
    managed_by  = "terraform"
    owner       = "brian-m-lasky"
  }
}
