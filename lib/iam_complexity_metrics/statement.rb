require_relative 'weights'
require_relative 'condition'
require_relative 'pseudo_functions'
require 'set'

class Statement
  include Weights
  include PseudoFunctions

  def metric(statement_hash)
    aggregate = weights[:Base_Statement]

    aggregate += weights[:Deny] if statement_hash['Effect'] == 'Deny'
    aggregate += weights[:Allow] if statement_hash['Effect'] == 'Allow'
    aggregate += weights[:NotAction] if statement_hash.has_key?('NotAction')
    aggregate += weights[:NotResource] if statement_hash.has_key?('NotResource')
    aggregate += extra_service_count(statement_hash) * weights[:Extra_Service]
    aggregate += misaligned_resource_action_count(statement_hash) * weights[:Resource_Action_NotAligned]
    aggregate += mixed_wildcard(statement_hash) * weights[:Mixed_Wildcard]

    if statement_hash.has_key? 'Condition'
      aggregate += Condition.new.metric(statement_hash)
    end
    aggregate
  end

  private

  def mixed_wildcard(statement_hash)
    count = 0
    count += 1 if action_service_names(statement_hash).include?('*') && action_service_names(statement_hash).size > 1
    count += 1 if resource_service_names(statement_hash).include?('*') && resource_service_names(statement_hash).size > 1
    count
  end

  def misaligned_resource_action_count(statement_hash)
    if resource(statement_hash).is_a?(String)
      return 0 if resource(statement_hash) == '*'
      resource_service_names = [resource_service_name(resource(statement_hash))]
    elsif resource(statement_hash).is_a?(Array)
      resource_service_names = resource(statement_hash).map { |resource_arn| resource_service_name(resource_arn) }
    end

    if action(statement_hash).is_a?(String)
      return 0 if action(statement_hash) == '*'
      action_service_names = [action_service_name(action(statement_hash))]
    elsif action(statement_hash).is_a?(Array)
      action_service_names = action(statement_hash).map { |action| action_service_name(action) }
    end

    (set_without_wildcard(resource_service_names) - set_without_wildcard(action_service_names)).size
  end

  def set_without_wildcard(array)
    Set.new(array).delete('*')
  end

  def extra_service_count(statement_hash)
    service_names = Set.new(action_service_names(statement_hash) + resource_service_names(statement_hash)).delete('*')
    [service_names.size - 1, 0].max
  end

  def action_service_names(statement_hash)
    if action(statement_hash).is_a?(String)
      [action_service_name(action(statement_hash))]
    elsif action(statement_hash).is_a?(Array)
      action(statement_hash).map { |resource_arn| action_service_name(resource_arn) }
    else
      []
    end
  end

  def resource_service_names(statement_hash)
    if resource(statement_hash).is_a?(String)
      [resource_service_name(resource(statement_hash))]
    elsif resource(statement_hash).is_a?(Array)
      resource(statement_hash).map { |resource_arn| resource_service_name(resource_arn) }
    else
      []
    end
  end

  def action_service_name(action)
    return '*' if action == '*'
    evaluate(action).split(':')[0]
  end

  def resource_service_name(resource_arn)
    return '*' if resource_arn == '*'
    evaluate(resource_arn).split(':')[2]
  end

  def action(statement_hash)
    return statement_hash['Action'] if statement_hash.has_key? 'Action'
    statement_hash['NotAction']
  end

  def resource(statement_hash)
    return statement_hash['Resource'] if statement_hash.has_key? 'Resource'
    statement_hash['NotResource']
  end
end