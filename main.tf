terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "mysql_replica_not_running_properly" {
  source    = "./modules/mysql_replica_not_running_properly"

  providers = {
    shoreline = shoreline
  }
}