resource "aws_iam_group" "blog_updater" {
  name = "blog_updater"
  path = "/volatile_thunk/"
}
