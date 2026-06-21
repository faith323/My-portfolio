data "aws_route53_zone" "this" {
    name = var.hosted_zone_name
    private_zone = false
}

resource "aws_route53_record" "cname_records" {
    for_each = var.cname_records

    zone_id = data.aws_route53_zone.this.zone_id
    name = each.key
    type = "CNAME"
    ttl = each.value.ttl

    records = [each.value.value]
}

