resource "aws_spot_instance_request" "RoboShop" {
  count                  = local.LENGTH
  ami                    = "ami-0e4e4b2f188e91845"
  spot_price             = "0.0031"
  instance_type          = "t3.micro"
  vpc_security_group_ids = ["sg-0342f3ac50a4bc8c6"]
  wait_for_fulfillment   = true
  //  spot_type              = "persistent"

  tags                   = {
    Name                 = "${element(var.COMPONENTS, count.index)}-${var.ENV}"
  }
}

#resource "aws_ec2_tag" "name-tag" {
#  count                  = local.LENGTH
#  resource_id            = element(aws_spot_instance_request.RoboShop.*.spot_instance_id, count.index)
#  key                    = "Name"
#  value                  = element(var.COMPONENTS, count.index)
#}

resource "aws_route53_record" "records" {
  count   = local.LENGTH
  name    = "${element(var.COMPONENTS, count.index)}-${var.ENV}"
  type    = "A"
  zone_id = "Z02807362V1O6GIFPEOSL"
  ttl     = 300
  records = [element(aws_spot_instance_request.RoboShop.*.private_ip, count.index)]
}

locals {
  LENGTH = length(var.COMPONENTS)
}

//COMPONENTS = ["mysql","mongodb","rabbitmq","redis","cart","shipping","catalogue","user","payment","frontend"]

resource "local_file" "inventory-file" {
  content = "[FRONTEND]\n${aws_spot_instance_request.RoboShop.*.private_ip[9]}\n[PAYMENT]\n${aws_spot_instance_request.RoboShop.*.private_ip[8]}\n[USER]\n${aws_spot_instance_request.RoboShop.*.private_ip[7]}\n[CATALOGUE]\n${aws_spot_instance_request.RoboShop.*.private_ip[6]}\n[SHIPPING]\n${aws_spot_instance_request.RoboShop.*.private_ip[5]}\n[CART]\n${aws_spot_instance_request.RoboShop.*.private_ip[4]}\n[REDIS]\n${aws_spot_instance_request.RoboShop.*.private_ip[3]}\n[RABBITMQ]\n${aws_spot_instance_request.RoboShop.*.private_ip[2]}\n[MONGODB]\n${aws_spot_instance_request.RoboShop.*.private_ip[1]}\n[MYSQL]\n${aws_spot_instance_request.RoboShop.*.private_ip[0]}"
  filename = "/tmp/inv-roboshop-${var.ENV}"
}

