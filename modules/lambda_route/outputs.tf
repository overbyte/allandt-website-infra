output "execution_policy_arn" {
  value = aws_iam_policy.this.arn
}

output "function_name" {
  value = aws_lambda_function.this.function_name
}
