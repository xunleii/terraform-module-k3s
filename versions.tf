terraform {
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "~> 2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 2.2"
    }
  }
  required_version = "~> 1.0"
}
