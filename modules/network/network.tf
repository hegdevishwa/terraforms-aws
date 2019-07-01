/**
Creates a vpc with 2 private and public subnets in two seperate AZs
*/

data "aws_availability_zones" "available" {}


resource "aws_vpc" "main" {
  //65,536 possible IP addresses
  cidr_block = "10.0.0.0/16"
  tags={
      Name=var.vpc-name
  }
}

//Crerate 2 private subnet - one in each AZ
resource "aws_subnet" "private" {
  count=2
  vpc_id=aws_vpc.main.id
  //4,096 Possible IP addresses.
  //The below expression resolves to 10.0.0.1/20
  cidr_block= cidrsubnet(aws_vpc.main.cidr_block,4,0+count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags={
      Name="private-${count.index}-${var.vpc-name}"
      VPC=var.vpc-name
      Type="private"
  }
}

//Crerate 2 public subnet - one in each AZ
resource "aws_subnet" "public" {
  count=2
  vpc_id=aws_vpc.main.id
  cidr_block= cidrsubnet(aws_vpc.main.cidr_block,4,10+count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags={
      Name="public-${count.index}-${var.vpc-name}"
      VPC=var.vpc-name
      Type="public"
  }
}

resource "aws_internet_gateway" "igw"{
  vpc_id=aws_vpc.main.id
  tags={
    Name="igw-${var.vpc-name}"
  }
}

resource "aws_route_table" "rtbs"{
    vpc_id=aws_vpc.main.id
    count=2
    tags={
      Name = count.index == 0 ? "public-route" : "private-route"
    }  
}

# resource "aws_route" "private"{
#   count=2
#   route_table_id = aws_route_table.rtbs[count.index].tags.Name.private-route.id
#   destination_cidr_block=aws_subnet.private.0.cidr_block
#   depends_on=["aws_route_table.rtbs"]
# }
