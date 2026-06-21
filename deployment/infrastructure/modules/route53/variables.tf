variable "hosted_zone_name" {
    description = "Existing Route53 hosted zone name"
    type = string
}

variable "cname_records" {
    description = "Map of CNAME records to create"
    
    type = map(object({
        ttl = number
        value = string
        }))
}

