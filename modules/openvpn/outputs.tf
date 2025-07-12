output "openvpn_instance_id" {
  description = "생성된 OpenVPN 인스턴스의 ID"
  value       = aws_instance.openvpn_instance.id
}

output "openvpn_public_ip" {
  description = "OpenVPN 인스턴스의 공인 IP 주소"
  value       = aws_instance.openvpn_instance.public_ip
}
