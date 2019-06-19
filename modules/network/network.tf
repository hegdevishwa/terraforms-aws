data "aws_availability_zones" "available" {}


resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags={
      Name="main"
  }
}

resource "aws_subnet" "private" {
  vpc_id=aws_vpc.main.id
  cidr_block= cidrsubnet(aws_vpc.main.cidr_block,4,1)
  availability_zone = data.aws_availability_zones.available.names[0]
  tags={
      Name="private-main"
      VPC="main"
      Type="private"
  }
  //count=2
  
}

resource "aws_subnet" "public" {
  vpc_id=aws_vpc.main.id
  cidr_block= cidrsubnet(aws_vpc.main.cidr_block,4,2)
  tags={
      Name="public-main"
      VPC="main"
      Type="public"
  }
  
}
