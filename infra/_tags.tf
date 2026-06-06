locals {
  tags = merge({
    Capability        = "Azure"
    Team              = "Azure Eagle"
    OwnerEmailAddress = var.tags["OwnerEmailAddress"]
    Project           = var.tags["Project"]
    Repository        = var.tags["Repository"]
  }, var.tags)
}
