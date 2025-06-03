output "openproject_tg_arn" {
  value = aws_lb_target_group.openproject_tg.arn
}

output "devlake_tg_arn" {
  value = aws_lb_target_group.devlake_tg.arn
}