output "execution_role_arn" {
  value = aws_iam_role._.arn
}

output "execution_policy_arn" {
  value = aws_iam_policy._.arn
}

output "function_name" {
  value = aws_lambda_function._.function_name
}

output "function_qualified_arn" {
  value = aws_lambda_function._.qualified_arn
}
