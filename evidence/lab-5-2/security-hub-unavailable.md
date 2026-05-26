Security Hub could not be enabled in this AWS account.

Command:
aws securityhub describe-hub --region us-east-1

Result:
SubscriptionRequiredException: The AWS Access Key Id needs a subscription for the service.

For this lab, CloudTrail was deployed and verified. Security Hub findings could not be captured due to account/service subscription restriction.
