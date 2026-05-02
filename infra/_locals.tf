locals {
  locations = {
    uksouth = "uks"
    ukwest  = "ukw"
  }
  location = local.locations[var.location]

  environment_short = {
    dev  = "D"
    test = "T"
    nprd = "N"
    prd  = "P"
    pprd = "S"
  }

  prefix       = "${var.project}-${var.environment}-${local.location}"
  prefix_short = "${var.project}${local.environment_short[var.environment]}${local.location}"
}
