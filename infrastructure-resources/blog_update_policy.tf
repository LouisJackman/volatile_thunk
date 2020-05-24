resource "aws_iam_policy" "blog_update" {
  name = "blog_update"
  path = "/volatile_thunk/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::volatilethunk.com",
        "arn:aws:s3:::volatilethunk.com/*"
      ]
    }
  ]
}
EOF

}

resource "aws_iam_policy_attachment" "blog_updater_policy_attachment" {
  name       = "blog-updater-policy-attachment"
  groups     = [aws_iam_group.blog_updater.name]
  policy_arn = aws_iam_policy.blog_update.arn
}

