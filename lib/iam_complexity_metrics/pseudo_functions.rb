module PseudoFunctions
  ##
  # best effort to turn into a string.... we only need the service bit of the arn
  # to align with actions
  #
  def evaluate(expression)
    if expression.is_a? String
      expression
    elsif expression.is_a? Hash
      if expression.has_key?('Fn::Join')
        join expression
      elsif expression.has_key?('Fn::Sub')
        sub expression
      elsif expression.has_key?('Fn::If')
        evaluate expression['Fn::If'][1]
      elsif expression.has_key?('Ref')
       "${#{expression['Ref']}}"
      elsif expression.has_key?('Fn::GetAtt')
        "${#{expression['Fn::GetAtt'][0]}.#{expression['Fn::GetAtt'][1]}}"
      end
    else
      expression.to_s
    end
  end

  def join(expression)
    delimiter =  expression['Fn::Join'][0]
    values = expression['Fn::Join'][1]
    values.reduce('') do |joined, value|
      if joined == ''
        evaluate(value)
      else
        joined + delimiter + evaluate(value)
      end
    end
  end

  def sub(expression)
    if expression['Fn::Sub'].is_a? String
      expression['Fn::Sub']
    elsif expression['Fn::Sub'].is_a? Array
      expression['Fn::Sub'][0]
    else
      expression.to_s
    end
  end

  # "Fn::If": [condition_name, value_if_true, value_if_false]
  # { "Fn::GetAtt" : [ "logicalNameOfResource", "attributeName" ] }
  # { "Fn::Join" : [ "delimiter", [ comma-delimited list of values ] ] }
  # { "Fn::Sub" : [ String, { Var1Name: Var1Value, Var2Name: Var2Value } ] }
  # { "Fn::Sub" : String }
end