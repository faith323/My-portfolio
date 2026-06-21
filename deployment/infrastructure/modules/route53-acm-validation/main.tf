data "aws_route53_zone" "this" {
    name = var.hosted_zone_name
    private_zone = false
}

resource "aws_route53_record" "acm_validation" {
    for_each = {
        for dvo in var.domain_validation_options :
        dvo.domain_name => {
            name = dvo.resource_record_name
            type = dvo.resource_record_type
            value = dvo.resource_record_value
        }
    }

    zone_id = data.aws_route53_zone.this.zone_id
    name = each.value.name
    type = each.value.type
    ttl = 60
    records = [each.value.value]
}

