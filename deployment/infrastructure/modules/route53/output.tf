output "created_records" {
    description = "created CNAME records"
    value = {
        for name, record in aws_route53_record.cname_records :
        name => record.fqdn
    }
}