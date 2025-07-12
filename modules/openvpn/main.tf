# 보안 그룹 생성: OpenVPN에 필요한 포트(HTTPS, UDP 1194, SSH)를 엽니다.
resource "aws_security_group" "openvpn_sg" {
  name        = "${var.stage}-${var.servicename}-openvpn-sg"
  description = "Security group for OpenVPN instance"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = var.allowed_cidr_blocks
  }

  ingress {
    description = "Allow OpenVPN UDP"
    from_port   = 1194
    to_port     = 1194
    protocol    = "UDP"
    cidr_blocks = var.allowed_cidr_blocks
  }

  ingress {
    description = "Allow Admin UI on port 943"
    from_port   = 943
    to_port     = 943
    protocol    = "TCP"
    cidr_blocks = var.allowed_cidr_blocks
  }

  ingress {
    description = "Allow Admin UI on port 945"
    from_port   = 945
    to_port     = 945
    protocol    = "TCP"
    cidr_blocks = var.allowed_cidr_blocks
  }

  ingress {
    description = "Allow SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(tomap({
         Name =  "aws-sg-${var.stage}-${var.servicename}"}),
        var.tags)
}

resource "aws_eip" "openvpn_eip" {
  instance = aws_instance.openvpn_instance.id
}

# OpenVPN 인스턴스 생성: 퍼블릭 서브넷에 배치하고, 공인 IP를 할당합니다.
resource "aws_instance" "openvpn_instance" {
  ami                         = var.ami_id           # 예: OpenVPN Access Server AMI ID
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id        # 퍼블릭 서브넷
  associate_public_ip_address = true
  key_name                    = "aws-keypair-${var.stage}-${var.servicename}" 
  vpc_security_group_ids      = [aws_security_group.openvpn_sg.id]

  root_block_device {
          delete_on_termination = true
          encrypted = true
          # kms_key_id = var.kms_key_id
          volume_size = var.ebs_size
  }

#   user_data = templatefile("${path.module}/user_data.sh", {
#     # 필요 시 OpenVPN 초기 설정 값을 전달할 수 있습니다.
#     cluster_name = var.cluster_name
#   })

  tags = merge(tomap({
         Name =  "aws-openvpn-${var.stage}-${var.servicename}"}),
        var.tags)
}
