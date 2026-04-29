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
  prefix_short = "${var.project}${local.environment_short[var.environment]}${local.location}" # 7 characters

  st_naming = {
    long  = replace("${local.prefix}-%sst-01", "-", "")
    short = lower("${local.prefix_short}%sst01")
  }
}

locals {
  all_group_names = flatten([
    for rbac_group in var.rbac_groups : rbac_group.group_members_names
  ])

  distinct_group_names = distinct(local.all_group_names)
}


