
output "be_instance_id" {
  description = "Backend EC2 instance ID"
  value       = try(module.be_app[0].instance_id, null)
}

output "be_public_ip" {
  description = "Backend EC2 public IP"
  value       = try(module.be_app[0].public_ip, null)
}

output "be_private_ip" {
  description = "Backend EC2 private IP"
  value       = try(module.be_app[0].private_ip, null)
}


output "fe_instance_id" {
  description = "Frontend EC2 instance ID"
  value       = try(module.fe_app[0].instance_id, null)
}

output "fe_public_ip" {
  description = "Frontend EC2 public IP"
  value       = try(module.fe_app[0].public_ip, null)
}

output "fe_private_ip" {
  description = "Frontend EC2 private IP"
  value       = try(module.fe_app[0].private_ip, null)
}


