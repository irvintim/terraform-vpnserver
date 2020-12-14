locals {
  global_tags = "${map(
    "Environment", var.environment,
    "Role", "awsvpn"
  )}"
  ssm_environment = replace(var.environment, "-", "_")
}
