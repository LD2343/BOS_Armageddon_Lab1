# Public Subnets
resource "aws_subnet" "brazil_public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.brazil_vpc01.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.name_prefix}-public-subnet-${count.index + 1}"
  }
}

# Private Subnets
resource "aws_subnet" "brazil_private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.brazil_vpc01.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "${local.name_prefix}-private-subnet-${count.index + 1}"
  }
}