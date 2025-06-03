resource "aws_instance" "openproject" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.subnet_1
  vpc_security_group_ids = [var.sg_id]
  associate_public_ip_address = true

  user_data = <<-EOT
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker
    docker run -dit -p 80:80 -e OPENPROJECT_SECRET_KEY_BASE=secret -e OPENPROJECT_HOST__NAME=0.0.0.0:80 -e OPENPROJECT_HTTPS=false openproject/community:12
  EOT

  tags = merge(var.tags, {
    Name = "${lookup(var.tags, "Name", "default")}-OpenProject"
  })
}

resource "aws_instance" "devlake" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.subnet_2
  vpc_security_group_ids = [var.sg_id]
  associate_public_ip_address = true

  user_data = <<-EOT
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io
    systemctl start docker
    git clone https://github.com/lavanya24072000/usecases.git
    cd usecases
    curl -SL https://github.com/docker/compose/releases/download/v2.33.1/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    docker-compose up -d
  EOT

  tags = merge(var.tags, {
    Name = "${lookup(var.tags, "Name", "default")}-DevLake"
  })
}

resource "aws_lb_target_group_attachment" "openproject_attach" {
  target_group_arn = var.openproject_tg_arn
  target_id        = aws_instance.openproject.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "devlake_attach" {
  target_group_arn = var.devlake_tg_arn
  target_id        = aws_instance.devlake.id
  port             = 4000
}