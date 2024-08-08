output "ids" {
  value = aws_eip.nat.*.id
}