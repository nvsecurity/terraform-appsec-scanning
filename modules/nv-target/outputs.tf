output "target_id" {
  value = null_resource.nightvision_target.id
  description = "The ID of the target created in NightVision. Useful for forcing dependency on the creation of targets."
}
