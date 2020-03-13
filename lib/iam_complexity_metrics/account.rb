require 'aws-sdk-iam'
require 'uri'

class Account
  def initialize(aws_profile)
    @aws_profile = aws_profile
  end

  def iam_metrics
    policy_documents = {}

    policies = iam.policies(
      scope: 'AWS', # Local
      only_attached: false,
      policy_usage_filter: 'PermissionsPolicy'
    )
    policies.each do |policy|
      policy_document_hash = YAML.load(URI.decode(policy.default_version.document))
      policy_documents[policy.policy_name] = PolicyDocument.new.metric(policy_document_hash)
    end

    # roles = iam.roles
    # roles.each do |role|
    #   role.policies.each do |policy|
    #     policy_document_hash = YAML.load(URI.decode(policy.policy_document))
    #     policy_documents[embedded_policy_id(policy)] = PolicyDocument.new.metric(policy_document_hash)
    #   end
    # end

    policy_documents
  end

  private

  def iam
    iam_client = Aws::IAM::Client.new(profile: @aws_profile)
    Aws::IAM::Resource.new(client: iam_client)
  end

  def embedded_policy_id(policy)
    "#{policy.role.name}_#{policy.name}"
  end
end