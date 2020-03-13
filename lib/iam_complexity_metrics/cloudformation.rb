require 'yaml'
require_relative 'policy_document'

class CloudFormation
  YAML.add_domain_type('', 'Ref') { |type, val| { 'Ref' => val } }

  YAML.add_domain_type('', 'GetAtt') do |type, val|
    if val.is_a? String
      val = val.split('.')
    end

    { 'Fn::GetAtt' => val }
  end

  %w(Join Base64 Sub Split Select ImportValue GetAZs FindInMap And Or If Not).each do |function_name|
    YAML.add_domain_type('', function_name) { |type, val| { "Fn::#{function_name}" => val } }
  end

  def iam_metrics(cfn_string)
    policy_documents = {}
    begin
      cfn_hash = YAML.load cfn_string
    rescue Psych::SyntaxError
      return []
    end
    return [] if cfn_hash == 'this is not legal json'
    return [] if !cfn_hash
    return [] unless cfn_hash.has_key? 'Resources'

    cfn_hash['Resources'].each do |logical_resource_id, resource|
      if resource['Type'] == 'AWS::IAM::Policy' || resource['Type'] == 'AWS::IAM::Policy'
        policy_documents[logical_resource_id] = PolicyDocument.new.metric(resource['Properties']['PolicyDocument'])
      elsif resource['Type'] == 'AWS::IAM::Role'
        if resource['Properties'].has_key? 'Policies'
          resource['Properties']['Policies'].each do |policy|
            policy_documents[embedded_policy_id(logical_resource_id, policy)] = PolicyDocument.new.metric(policy['PolicyDocument'])
          end
        end
      end
    end
    policy_documents
  end

  private

  def embedded_policy_id(role_id, policy)
    role_id + '_' + policy['PolicyName'].to_s
  end
end