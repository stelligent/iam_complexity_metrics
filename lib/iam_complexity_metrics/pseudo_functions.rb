module PseudoFunctions
  ##
  # best effort to turn into a string.... we only need the service bit of the arn
  # to align with actions
  #
  def evaluate(expression)
    puts expression.class
    if expression.is_a? String
      expression
    elsif expression.is_a? Hash
      if expression.has_key?('Fn::Join')
        join expression
      elsif expression.has_key?('Fn::Sub')
        sub expression
      elsif expression.has_key?('Fn::If')
        evaluate expression['Fn::If'][1]
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
    if expression['Fn::Sub'][1].is_a? String
      expression
    elsif expression['Fn::Sub'][1].is_a? Array
      expression['Fn::Sub'][1][0]
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