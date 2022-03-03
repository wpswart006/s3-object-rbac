
resource "aws_lambda_function" "test_lambda" {
  filename      = data.archive_file.archive.output_path
  function_name = "object_rbac_demo_lambda"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "app.lambda_handler"

  source_code_hash = filebase64sha256("lambda_function_package.zip")


  runtime = "python3.9"

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.b.bucket
    }
  }

}

data "archive_file" "archive" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda_function_package.zip"
  
#   depends_on = [null_resource.lambda_exporter]
}
