resource "aws_s3_bucket" "b" {
  bucket = "object-rbac-demo"

  tags = {
    Owner = "Willem"
  }
}

resource "aws_s3_bucket_public_access_block" "b" {
  bucket = aws_s3_bucket.b.id

  block_public_acls   = true
  block_public_policy = true
}

# resource "aws_s3_bucket_object" "Cups" {
#   bucket = aws_s3_bucket.b
#   key    = "cups_object"

#   tags = {
#     Owner    = "Willem"
#     TeamCode = "blue"
#   }

# }

# resource "aws_s3_bucket_object" "Saucers" {
#   bucket = aws_s3_bucket.b.bucket_name
#   key    = "saucers_object"

#   tags = {
#     Owner    = "Willem"
#     TeamCode = "red"
#   }

# }

resource "aws_s3_object" "red_object" {
  bucket = aws_s3_bucket.b.bucket
  key    = "Cups"

  tags = {
    Owner  = "Willem"
    access = "red"
  }

}

resource "aws_s3_object" "blue_object" {
  bucket = aws_s3_bucket.b.bucket
  key    = "Saucers"

  tags = {
    Owner  = "Willem"
    access = "blue"
  }

}

resource "aws_s3_object" "purple_object" {
  bucket = aws_s3_bucket.b.bucket
  key    = "Mugs"

  tags = {
    Owner  = "Willem"
    access = "blue+red"
  }

}

resource "aws_s3_access_point" "example" {
  bucket = aws_s3_bucket.b.id
  name   = "object-rbac-demo"
}

resource "aws_s3control_object_lambda_access_point" "example" {
  name = "object-rbac-demo-lambda-access-point"

  configuration {
    supporting_access_point = aws_s3_access_point.example.arn

    transformation_configuration {
      actions = ["GetObject"]

      content_transformation {
        aws_lambda {
          function_arn = aws_lambda_function.test_lambda.arn
        }
      }
    }
  }
}