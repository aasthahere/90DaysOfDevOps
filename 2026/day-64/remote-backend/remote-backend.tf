resource "aws_s3_bucket" "remote-s3-bucket" {
  bucket = "terraweek-state-aliya"
  tags = {
    Name = "terraweek-state-aliya"
  }

}


#dynomodb table for terraform state locking
resource "aws_dynamodb_table" "remote_dynamodb_table" {
  name         = "terraform-lock-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
