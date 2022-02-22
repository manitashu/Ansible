
resource "aws_instance" "app-instances" {
  count                  = length(var.APP_COMPONENTS)
  ami                    = "ami-0e4e4b2f188e91845"
  spot_price             = "0.0031"
  instance_type          = "t3.micro"
  vpc_security_group_ids = ["sg-0342f3ac50a4bc8c6"]
  wait_for_fulfillment   = true
  //  spot_type              = "persistent"

  tags                   = {
    Name                 = "${element(var.APP_COMPONENTS, count.index)}-${var.ENV}"
    Monitor              = "yes"
  }
}

resource "aws_instance" "db-instances" {
  count                  = length(var.DB_COMPONENTS)
  ami                    = "ami-0e4e4b2f188e91845"
  spot_price             = "0.0031"
  instance_type          = "t3.micro"
  vpc_security_group_ids = ["sg-0342f3ac50a4bc8c6"]
  wait_for_fulfillment   = true
  //  spot_type              = "persistent"

  tags                   = {
    Name                 = "${element(var.DB_COMPONENTS, count.index)}-${var.ENV}"
  }
}

#resource "aws_ec2_tag" "name-tag" {
#  count                  = local.LENGTH
#  resource_id            = element(aws_spot_instance_request.RoboShop.*.spot_instance_id, count.index)
#  key                    = "Name"
#  value                  = element(var.COMPONENTS, count.index)
#}

resource "aws_route53_record" "app-records" {
  count   = length(var.APP_COMPONENTS)
  name    = "${element(var.APP_COMPONENTS, count.index)}-${var.ENV}"
  type    = "A"
  zone_id = "Z02807362V1O6GIFPEOSL"
  ttl     = 300
  records = [element(aws_instance.app-instances.*.private_ip, count.index)]
}

resource "aws_route53_record" "db-records" {
  count   = length(var.DB_COMPONENTS)
  name    = "${element(var.DB_COMPONENTS, count.index)}-${var.ENV}"
  type    = "A"
  zone_id = "Z02807362V1O6GIFPEOSL"
  ttl     = 300
  records = [element(aws_instance.db-instances.*.private_ip, count.index)]
}

//COMPONENTS = ["mysql","mongodb","rabbitmq","redis","cart","shipping","catalogue","user","payment","frontend"]

#resource "local_file" "inventory-file" {
#  content = "[FRONTEND]\n${aws_spot_instance_request.RoboShop.*.private_ip[9]}\n[PAYMENT]\n${aws_spot_instance_request.RoboShop.*.private_ip[8]}\n[USER]\n${aws_spot_instance_request.RoboShop.*.private_ip[7]}\n[CATALOGUE]\n${aws_spot_instance_request.RoboShop.*.private_ip[6]}\n[SHIPPING]\n${aws_spot_instance_request.RoboShop.*.private_ip[5]}\n[CART]\n${aws_spot_instance_request.RoboShop.*.private_ip[4]}\n[REDIS]\n${aws_spot_instance_request.RoboShop.*.private_ip[3]}\n[RABBITMQ]\n${aws_spot_instance_request.RoboShop.*.private_ip[2]}\n[MONGODB]\n${aws_spot_instance_request.RoboShop.*.private_ip[1]}\n[MYSQL]\n${aws_spot_instance_request.RoboShop.*.private_ip[0]}"
#  filename = "/tmp/inv-roboshop-${var.ENV}"
#}
locals {
  COMPONENTS = concat(var.APP_COMPONENTS, var.DB_COMPONENTS)
}

resource "local_file" "inventory-file" {
  content = "[FRONTEND]\n${local.COMPONENTS[9]}\n[PAYMENT]\n${local.COMPONENTS[8]}\n[USER]\n${local.COMPONENTS[7]}\n[CATALOGUE]\n${local.COMPONENTS[6]}\n[SHIPPING]\n${local.COMPONENTS[5]}\n[CART]\n${local.COMPONENTS[4]}\n[REDIS]\n${local.COMPONENTS[3]}\n[RABBITMQ]\n${local.COMPONENTS[2]}\n[MONGODB]\n${local.COMPONENTS[1]}\n[MYSQL]\n${local.COMPONENTS[0]}"
  filename = "/tmp/inv-roboshop-${var.ENV}"
}

// to avoid do manually changes, we can use concat function and combine both lists

#resource "local_file" "inventory-file" {
#  content = "[FRONTEND]\n${aws_instance.app-instances.*.private_ip[5]}\n[PAYMENT]\n${aws_instance.app-instances.*.private_ip[4]}\n[USER]\n${aws_instance.app-instances.*.private_ip[3]}\n[CATALOGUE]\n${aws_instance.app-instances.*.private_ip[2]}\n[SHIPPING]\n${aws_instance.app-instances.*.private_ip[1]}\n[CART]\n${aws_instance.app-instances.*.private_ip[0]}\n[REDIS]\n${aws_instance.db-instances.*.private_ip[3]}\n[RABBITMQ]\n${aws_instance.db-instances.*.private_ip[2]}\n[MONGODB]\n${aws_instance.db-instances.*.private_ip[1]}\n[MYSQL]\n${aws_instance.db-instances.*.private_ip[0]}"
#  filename = "/tmp/inv-roboshop-${var.ENV}"
#}



