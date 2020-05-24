resource "aws_iam_role" "blog_lambda_role" {
  name = "volatile-thunk-add-http-headers"
  path = "/service-role/"

  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action = "sts:AssumeRole"
          Principal = {
            Service = [
              "lambda.amazonaws.com",
              "edgelambda.amazonaws.com",
            ]
          }
          Effect = "Allow"
          Sid    = ""
        }
      ]
    }
  )
}

resource "aws_iam_policy" "blog_lambda_role" {

  // This odd-looking name comes from an imported managed policy.
  name = "AWSLambdaEdgeExecutionRole-0016bfe0-1de1-4385-ace2-7cef23129735"

  path = "/service-role/"

  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
          ]
          Resource = [
            "arn:aws:logs:*:*:*",
          ]
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "blog_lambda_role" {
  role       = aws_iam_role.blog_lambda_role.name
  policy_arn = aws_iam_policy.blog_lambda_role.arn
}
