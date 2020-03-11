require 'iam_complexity_metrics/cloudformation'

template = <<END
{
  "Resources": {
    "SomeGroup": {
      "Type": "AWS::IAM::Group"
    },

    "NotActionPolicy": {
      "Type": "AWS::IAM::Policy",
      "Properties": {
        "PolicyName": "somePolicy",
        "PolicyDocument": {
          "Version": "2012-10-17",
          "Statement": [
            {
              "Effect": "Allow",
              "NotAction": "rds:CreateDBInstance",
              "Resource": {
                "Fn::Join": [
                  "",
                  [
                    "arn:aws:rds:",
                    {
                      "Ref": "AWS::Region"
                    },
                    ":",
                    {
                      "Ref": "AWS::AccountId"
                    },
                    ":db:test*"
                  ]
                ]
              },
              "Condition": {
                "StringEquals": {
                  "rds:DatabaseEngine": "mysql"
                }
              }
            }
          ]
        },
        "Groups": [
          {"Ref":"SomeGroup"}
        ]
      }
    }
  }
}
END

describe CloudFormation do
  it 'returns a number' do
    expect(CloudFormation.new.iam_metrics(template)).to eq({'NotActionPolicy' => 4})
  end
end