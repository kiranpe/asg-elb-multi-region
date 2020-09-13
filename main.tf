provider "aws" {
   profile = "Terraform"
   region  = "us-east-1"
}

provider "aws" {
   profile = "Terraform"
   alias   = "east-2"
   region  = "us-east-2"
}

module "us-east-1" {
   source = "./multi_region"
  
   providers = {
    aws = aws
   }
}


module "us-east-2" {
   source = "./multi_region"
   
   providers = {
    aws = aws.east-2
   }
}
