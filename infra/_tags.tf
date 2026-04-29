locals {
  tags = merge({
    Capability        = "Azure"                                                   # Required
    Team              = "Azure Eagle"                                             # Required
    OwnerEmailAddress = ""                                                        # Required
    Project           = "Azure Capability Spoke Accelerators - Virtual Assistant" # Required
    Repository        = ""                                                        # Required
    Deployment-date   = formatdate("DD/MM/YYYY hh:mm:ss", timestamp())            # Required
    # Contact                 = "admin@email.com"
    # Business-unit           = "TBC"
    # Business-unit-sponsor   = "TBC"
    # Cost-centre             = "TBC"
    # Data-classification     = "TBC"
    # Application-criticality = "TBC"
    # Application-name        = "TBC"
    # Application-owner       = "TBC"
    },
    var.tags
  )
}