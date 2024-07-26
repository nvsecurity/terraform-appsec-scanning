output "directory_hash" {
  value       = data.external.directory_hash.result
  description = "The hash of the directory containing the code that generates the OpenAPI spec."
}

output "selected_language" {
  description = "The language selected for the code base."
  value       = var.language
}
