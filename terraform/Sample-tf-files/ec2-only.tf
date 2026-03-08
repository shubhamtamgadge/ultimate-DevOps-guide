resource "aws_instance" "server" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"
  key-name      = "aws"

  tags = {
    Name = "DevOps-Server"
  }
}
