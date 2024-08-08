resource "aws_eip" "nat" {
  count  = var.num_eips
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-ip-${count.index}"
  }
}
