require_relative 'statement'

class PolicyDocument
  def metric(policy_document_hash)
    if policy_document_hash['Statement'].is_a? Hash
      Statement.new.metric(policy_document_hash['Statement'])
    elsif policy_document_hash['Statement'].is_a? Array
      policy_document_hash['Statement'].reduce(0) do |aggregate, statement|
        aggregate + Statement.new.metric(statement)
      end
    end
  end
end