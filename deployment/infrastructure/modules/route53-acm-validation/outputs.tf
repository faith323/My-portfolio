output "validation_record_fqdns" {
    value = [for r in aws_route53_record.acm_validation : r.fqdn]
}