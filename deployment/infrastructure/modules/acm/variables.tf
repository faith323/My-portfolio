variable "domain_name" {
    description = "Primary domain name for the ACM certificate"
    type = string
}

variable "subject_alternative_names" {
    description = "Additional domains for the certificate"
    type = list(string)
    default = []
}

variable "validation_method" {
    description = "Method used to validate the certificate"
    type = string
    default = "DNS"
}

variable "tags" {
    description = "Tags to apply to the ACM certificate"
    type = map(string)
    default = {}
}

