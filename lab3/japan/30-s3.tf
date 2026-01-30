terraform {
  backend "s3" {
    bucket = "japan-medical-s3-backend-891377135193" # your existing bucket
    key    = "edo/ap-northeast-1/terraform.tfstate"
    region = "ap-northeast-1" # bucket region
    # encrypt        = true
    #dynamodb_table = "terraform-locks"                  # optional but strongly recommended for locking
  }
}