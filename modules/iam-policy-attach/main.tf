resource "aws_iam_policy_attachment" "test-attach" {
  name       = "${var.iam_name}-att"
  roles      = ["${var.role_name}"]
  policy_arn = "${var.arn}"
}