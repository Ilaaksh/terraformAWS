provider "aws" {
  region= "us-east-1"
}

#Create a  VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "VPC"
  }
}

#Create a Internet Gateway
resource "aws_internet_gateway" "aws_IG" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Internet Gateway"
  }
}

#Creating a Custom Route Table
resource "aws_route_table" "aws_RT" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0" //Keeping it as default server
    gateway_id = aws_internet_gateway.aws_IG.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.aws_IG.id
  }

  tags = {
    Name = "Custom Route Table"
  }
}

#Creating a Subnet
resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.vpc.id //Referencing the resources which was declared above
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Subnet"
  }
}

# Linking Subnet and Route table
resource "aws_route_table_association" "name" {
  subnet_id = aws_subnet.subnet.id
  route_table_id = aws_route_table.aws_RT.id
}

# Creating a Security Group
resource "aws_security_group" "aws_sg" {
  name = "allow web traffic"
  description = "Allow TLS traffic"
  vpc_id = aws_vpc.vpc.id

  ingress  {
    description = "HTTPS"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress  {
    description = "HTTP"
    from_port = 80
    to_port =  80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress  {
    description = "SSH"
    from_port = 2
    to_port =  2
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

//Creating a AWS network interface
resource "aws_network_interface" "aws_ni" {
  subnet_id       = aws_subnet.subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.aws_sg.id]
}

//Creating an elasticIP with ref to network interface
resource "aws_eip" "aws_elasticip" {
  domain = "vpc"
  network_interface         = aws_network_interface.aws_ni.id
  associate_with_private_ip = "10.0.1.50"
  //Using for an extranal dependency
  depends_on = [aws_internet_gateway.aws_IG]
}

//Creating Ubuntu web server and enablling apache on it

resource "aws_instance" "web-server" {
  ami = "ami-0b0ea68c435eb488d"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  key_name = "main-key"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.aws_ni.id
  }
  user_data = <<EOF
        #!/bash/bin
        sudo apt update -y
        sudo apt install apache2 -y
        sudo systemctl start apache2
        sudo bash -c 'echo Server Working > /var/www/html/index.html'
        EOF
  tags = {
    Name = "Web-Server"
  }
}

