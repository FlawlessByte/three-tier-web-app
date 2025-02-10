region = "eu-west-2"
name   = "prod-euw2-shared1"
vpc_cidr   = "10.100.0.0/21"
public_subnet_names = [
  "public-eu-west-2a.prod-euw2-shared1",
  "public-eu-west-2b.prod-euw2-shared1"
]
private_subnet_names = [
  "private-eu-west-2a.prod-euw2-shared1",
  "private-eu-west-2b.prod-euw2-shared1"
]

public_subnets = [
  "10.100.4.0/23",
  "10.100.6.0/23"
]

private_subnets = [
  "10.100.0.0/23",
  "10.100.2.0/23"
]

tags = {
  "Environment" = "production"
  "CreatedBy"   = "terraform"
}
