/**
Creates a vpc with 2 private and public subnets in two seperate AZs
*/
#############################################
# DATA
#############################################

data "aws_availability_zones" "available" {}


#############################################
# RESOURCES
#############################################

# VPC #
resource "aws_vpc" "main" {
  //65,536 possible IP addresses
  cidr_block = var.network_address_space
  enable_dns_hostnames= true
  tags={
      Name=var.vpc_name
  }
}

# SUBNETS #
//Crerate 2 private subnet - one in each AZ
resource "aws_subnet" "private" {
  count=length(data.aws_availability_zones.available.names)
  vpc_id=aws_vpc.main.id
  //4,096 Possible IP addresses.
  //The below expression resolves to 10.0.0.1/20
  cidr_block= cidrsubnet(var.network_address_space,4,0+count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags={
      Name="private-${count.index}-${var.vpc_name}"
      VPC=var.vpc_name
      Type="private"
  }
}

//Crerate 2 public subnet - one in each AZ
resource "aws_subnet" "public" {
  count=length(data.aws_availability_zones.available.names)
  vpc_id=aws_vpc.main.id
  cidr_block= cidrsubnet(var.network_address_space,4,10+count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  //this is required so that an instance launched in the public subnet gets a public up
  map_public_ip_on_launch=true 
  tags={
      Name="public-${count.index}-${var.vpc_name}"
      VPC=var.vpc_name
      Type="public"
  }
}


# INTERNET GATEWAYS #
resource "aws_internet_gateway" "igw"{
  vpc_id=aws_vpc.main.id
  tags={
    Name="igw-${var.vpc_name}"
  }
}

#### ROUTE TABLES ####

# PUBLIC ROUTE #
resource "aws_route_table" "rtb-public"{
    vpc_id=aws_vpc.main.id
  
    tags={
      Name = "public-route"
    }  
    route{
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
    }
}

#### ROUTE TABLE ASSOCIATION #### 

# PUBLIC ROUTE TABLE ASSOCIATION TO PUBLIC SUBNETS #
resource "aws_route_table_association" "rta-public"{
  count=length(data.aws_availability_zones.available.names)
  subnet_id = element(aws_subnet.public.*.id,  count.index)
  route_table_id = aws_route_table.rtb-public.id  
}

#### SECURITY GROUP ####

# WEB SECURITY GROUP #
resource "aws_security_group" "web-sg"{
  name="web-sg-${aws_vpc.main.id}"
  description = "allow inboud web traffic"
  vpc_id = aws_vpc.main.id
 

  #HTTP access from anywhere
  ingress {
    from_port = 80
    to_port=80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name="web-sg-${aws_vpc.main.id}"
    vpc=aws_vpc.main.id
  }

}
