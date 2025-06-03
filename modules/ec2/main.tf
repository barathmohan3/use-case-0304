resource "aws_instance" "devlake" {
 ami                         = var.ami
 instance_type               = var.instance_type
 subnet_id                   = var.subnet_2
 vpc_security_group_ids      = [var.sg_id]
 associate_public_ip_address = true
 user_data = <<-EOT
   #!/bin/bash
   apt-get update -y
   apt-get install -y docker.io curl
   systemctl start docker
   systemctl enable docker
   # Install docker-compose
   curl -SL https://github.com/docker/compose/releases/download/v2.33.1/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
   chmod +x /usr/local/bin/docker-compose
   # Create app directory and docker-compose.yaml
   mkdir -p /opt/devlake
   cd /opt/devlake
   cat > docker-compose.yaml <<'EOF'
   version: '3.9'
   services:
     mysql:
       image: mysql:8
       environment:
         MYSQL_ROOT_PASSWORD: root
         MYSQL_DATABASE: lake
         MYSQL_USER: merico
         MYSQL_PASSWORD: merico
       volumes:
         - mysql-data:/var/lib/mysql
       ports:
         - "3306:3306"
     lake:
       image: mericodev/devlake:latest
       depends_on:
         - mysql
       ports:
         - "8080:8080"
     config-ui:
       image: mericodev/devlake-config-ui:latest
       depends_on:
         - lake
       ports:
         - "4000:4000"
     grafana:
       image: mericodev/devlake-dashboard:latest
       ports:
         - "3002:3000"
       volumes:
         - grafana-storage:/var/lib/grafana
       environment:
         GF_SERVER_ROOT_URL: "http://0.0.0.0:4000/grafana"
         GF_USERS_DEFAULT_THEME: "light"
         MYSQL_URL: mysql:3306
         MYSQL_DATABASE: lake
         MYSQL_USER: merico
         MYSQL_PASSWORD: merico
       depends_on:
         - mysql
   volumes:
     mysql-data:
     grafana-storage:
   EOF
   # Start containers
   /usr/local/bin/docker-compose up -d
 EOT
 tags = merge(var.tags, {
   Name = "${lookup(var.tags, "Name", "default")}-DevLake"
 })
}

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
    docker run -dit -p 80:80 -e OPENPROJECT_SECRET_KEY_BASE=secret -e OPENPROJECT_HOST__NAME=0.0.0.0:80 -e OPENPROJECT_HTTPS=false openproject/community:12Add commentMore actions
  EOT

  tags = merge(var.tags, {
    Name = "${lookup(var.tags, "Name", "default")}-OpenProject"
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

