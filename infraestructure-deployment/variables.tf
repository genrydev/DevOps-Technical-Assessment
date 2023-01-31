variable "location_zone" {
  default     = "eastus"
  description = "Location of the resource group."
}

variable "resource_group_name" {
  default     = "rg-dta"
  description = "DevOps Technical Assessment resource group name."
}

# variable "container_apps" {
#   type = list(object({
#     name = string
#     image = string
#     tag = string
#     containerPort = number
#     ingress_enabled = bool
#     min_replicas = number
#     max_replicas = number
#     cpu_requests = number
#     mem_requests = string
#   }))

#   default = [ {
#    image = "thorstenhans/gopher"
#    name = "herogopher"
#    tag = { "environment":"test" }
#    containerPort = 80
#    ingress_enabled = true
#    min_replicas = 1
#    max_replicas = 2
#    cpu_requests = 0.5
#    mem_requests = "0.2Gi"
#   },
#   {
#    image = "thorstenhans/gopher"
#    name = "devilgopher"
#    tag = { "environment":"prod" }
#    containerPort = 80
#    ingress_enabled = true
#    min_replicas = 1
#    max_replicas = 2
#    cpu_requests = 0.5
#    mem_requests = "0.2Gi"
#   }] 
# }