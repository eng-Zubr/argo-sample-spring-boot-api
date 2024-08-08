A separate resource for provisioning an Elastic IP for NAT gateway(s).

By default, the Terraform Registry Module [`/terraform-aws-modules/vpc/aws`](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest#external-nat-gateway-ips) will provision new Elastic IPs for the VPC's NAT Gateways. This means that when creating a new VPC, new IPs are allocated, and when that VPC is destroyed those IPs are released. Sometimes it is handy to keep the same IPs even after the VPC is destroyed and re-created. To that end, it is possible to assign existing IPs to the NAT Gateways. This prevents the destruction of the VPC from releasing those IPs, while making it possible that a re-created VPC uses the same IPs.

To achieve this, we need to allocate the IPs outside of the VPC module declaration. Then, pass the allocated IPs as a parameter to the VPC module.

```
# Example, the rest of arguments are omitted for brevity
enable_nat_gateway  = true
single_nat_gateway  = false
reuse_nat_ips       = true                    # <= Skip creation of EIPs for the NAT Gateways
external_nat_ip_ids = "${aws_eip.nat.*.id}"   # <= IPs specified here as input to the module
```