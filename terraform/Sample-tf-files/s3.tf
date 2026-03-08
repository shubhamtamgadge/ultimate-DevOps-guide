resource "aws_s3_bucket" "storage_bucket" {
  bucket = "my-terraform-demo-bucket"

  tags = {
    Name = "TerraformBucket"
  }
}
