output "blog_updater_user_access_key_id" {
  value = aws_iam_access_key.blog_updater.id
}

output "blog_updater_user_secret_access_key" {
  value = aws_iam_access_key.blog_updater.secret
}

