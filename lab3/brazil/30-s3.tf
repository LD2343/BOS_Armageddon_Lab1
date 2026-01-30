terraform {
  backend "s3" {
    bucket         = "brazil-medical-s3-backend-891377135193"          # your existing bucket
    key            = "gru/ap-northeast-1/terraform.tfstate"
    region         = "sa-east-1"                        # bucket region
  #  encrypt        = true
    #dynamodb_table = "terraform-locks"                  # optional but strongly recommended for locking
  }
}