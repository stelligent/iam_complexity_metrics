## Prerequisites

1. Install Ruby 2.5 or greater
2. Install bundler if need be
3. bundle install

## SPCM for CloudFormation Templates

To compute the Stelligent Policy Complexity Metric (SPCM) against a directory of CloudFormation templates:

```rake cfn_iam_metrics[/var/tmp/aws_sample_templates]```

where /var/tmp/aws_sample_templates is a directory containing templates ending in either .yml, .yaml, .json, or .template

The parser is very limited and best effort around ignoring pseudo-functions and dynamic values embedded inside policy 
documents.

## SPCM for Live IAM Policy Documents

To compute the Stelligent Policy Complexity Metric (SPCM) against all the AWS Managed Policy documents
in an account:

```rake live_iam_metrics[aws_profile]```

where aws_profile is the name of the aws_profile to use to access the live AWS account, e.g. labs, dev, prod, etc.
