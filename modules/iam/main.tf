resource "aws_iam_group" "zabbix-readonly" {
    name = "zabbix-readonly"
    path = "/users/"
}

data "aws_iam_policy" "ReadOnlyAccess" {
    name = "ReadOnlyAccess"
    description = "Default user policy"
}

resource "aws_iam_group_policy_attachment" "zabbix-attach-policy" {
    group = aws_iam_group.zabbix-readonly
    policy_arn = data.aws_iam_policy.ReadOnlyAccess.arn
}