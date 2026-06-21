variable "hosted_zone_name" {
    type = string
}

variable "domain_validation_options" {
    description = "ACM domain validation options"
    type = list(object({
        domain_name = string
        resource_record_name = string
        resource_record_type = string
        resource_record_value = string
    }))
}