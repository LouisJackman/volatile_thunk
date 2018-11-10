resource "aws_iam_user" "blog_updater" {
  name = "volatile_thunk_blog_updater"
  path = "/volatile_thunk/"
}

resource "aws_iam_access_key" "blog_updater" {
  user = "${aws_iam_user.blog_updater.name}"
}

resource "aws_iam_user_group_membership" "blog_updater_membership" {
  user = "${aws_iam_user.blog_updater.name}"

  groups = [
    "${aws_iam_group.blog_updater.name}",
  ]
}
