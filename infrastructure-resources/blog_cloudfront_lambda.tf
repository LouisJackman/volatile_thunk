data "archive_file" "blog_lambda" {
  type        = "zip"
  source_file = "${path.module}/files/index.js"
  output_path = "${path.module}/files/lambda_function_payload.zip"
}

resource "aws_lambda_function" "blog_lambda" {
  provider = aws.aws_us

  filename         = data.archive_file.blog_lambda.output_path
  function_name    = "arn:aws:lambda:us-east-1:799406373546:function:volatile-thunk-add-http-headers"
  role             = aws_iam_role.blog_lambda_role.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.blog_lambda.output_base64sha256
  timeout          = 1
  publish          = true
  runtime          = "nodejs12.x"
}
