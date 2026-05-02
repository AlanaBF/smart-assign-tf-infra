locals {
  tags = merge({
    Capability        = "Azure"
    Team              = "Azure Eagle"
    OwnerEmailAddress = var.tags["OwnerEmailAddress"]
    Project           = var.tags["Project"]
    Repository        = var.tags["Repository"]
    Deployment-date   = formatdate("DD/MM/YYYY hh:mm:ss", timestamp())
  }, var.tags)
}
