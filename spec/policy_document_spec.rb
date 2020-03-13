require 'iam_complexity_metrics/policy_document'

describe PolicyDocument do
  context 'one statement' do
    it 'metric matches the one statement metric' do
      policy_document_hash = {
        'Statement' =>
          {
            'Effect' => 'Deny',
            'Action' => 'fred:YellAtDino',
            'Resource' => 'arn:aws:fred:us-east-1:3333333333:dino'
          }
      }
      actual_metric = PolicyDocument.new.metric policy_document_hash
      expected_metric = 2
      expect(actual_metric).to eq(expected_metric)
    end
  end

  context 'two statements' do
    it 'metric matches the two statements metric' do
      policy_document_hash = {
        'Statement' => [
          {
            'Effect' => 'Allow',
            'Action' => 'fred:YellAtDino',
            'Resource' => 'arn:aws:fred:us-east-1:3333333333:dino'
          },
          {
            'Effect' => 'Allow',
            'Action' => 'fred:YellAtDino2',
            'Resource' => 'arn:aws:fred:us-east-1:3333333333:dino2'
          }
        ]
      }
      actual_metric = PolicyDocument.new.metric policy_document_hash
      expected_metric = 2
      expect(actual_metric).to eq(expected_metric)
    end
  end

  # context 'two competing statements' do
  #   it 'metric matches the two statements metric' do
  #     policy_document_hash = {
  #       'Statement' => [
  #         {
  #           'Effect' => 'Allow',
  #           'Action' => 'fred:YellAtDino',
  #           'Resource' => 'arn:aws:fred:us-east-1:3333333333:dino'
  #         },
  #         {
  #           'Effect' => 'Deny',
  #           'Action' => 'fred:YellAtDino',
  #           'Resource' => 'arn:aws:fred:us-east-1:3333333333:dino'
  #         }
  #       ]
  #     }
  #     actual_metric = PolicyDocument.new.metric policy_document_hash
  #     expected_metric = 3
  #     expect(actual_metric).to eq(expected_metric)
  #   end
  # end
end
