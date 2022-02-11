# How to apply
terraform apply -var profile=$PROFILE_NAME -var region=$AWS_REGION -var accountId=$AWS_ACCOUNT_ID -var repo=$GITHUB_REPO -var token=$GITHUB_TOKEN  -var runner_name=$AWS_RUNNER_NAME
