require 'iam_complexity_metrics/statement'


describe Statement do
  describe '#metric' do
    context 'simple statement' do
      it 'returns 1' do
        statement_hash = {
          'Effect' => 'Allow',
          'Action' => 'fred:YellAtDino',
          'Resource' => 'arn:aws:fred:us-east-1:3333333333:dino'
        }
        actual_metric = Statement.new.metric statement_hash
        expected_metric = 1
        expect(actual_metric).to eq(expected_metric)
      end
    end

    context 'deny statement' do
      it 'returns 2' do
        statement_hash = {
          'Effect' => 'Deny',
          'Action' => 'fred:YellAtDino',
          'Resource' => 'arn:aws:fred:us-east-1:3333333333:dino'
        }
        actual_metric = Statement.new.metric statement_hash
        expected_metric = 2
        expect(actual_metric).to eq(expected_metric)
      end
    end

    context 'Deny + notaction statement' do
      it 'returns 3' do
        statement_hash = {
          'Effect' => 'Deny',
          'NotAction' => 'fred:YellAtDino',
          'Resource' => 'arn:aws:fred:us-east-1:3333333333:dino'
        }
        actual_metric = Statement.new.metric statement_hash
        expected_metric = 3
        expect(actual_metric).to eq(expected_metric)
      end
    end

    context 'NotResource statement' do
      it 'returns 3' do
        statement_hash = {
          'Effect' => 'Allow',
          'Action' => 'fred:YellAtDino',
          'NotResource' => 'arn:aws:fred:us-east-1:3333333333:dino'
        }
        actual_metric = Statement.new.metric statement_hash
        expected_metric = 2
        expect(actual_metric).to eq(expected_metric)
      end
    end

    context '5 unique services mentioned in Resource' do
      it 'returns .1' do
        statement_hash = {
          'Effect' => 'Allow',
          'Action' => 'fred:YellAtDino',
          'Resource' => %w[
            arn:aws:fred:us-east-1:3333333333:dino
            arn:aws:wilma:us-east-1:3333333333:dino
            arn:aws:wilma:us-east-1:3333333333:dino
            arn:aws:zebra:us-east-1:3333333333:dino
            arn:aws:alpha:us-east-1:3333333333:dino
            arn:aws:beta:us-east-1:3333333333:dino
          ]
        }
        actual_metric = Statement.new.metric statement_hash
        expected_metric = 9
        expect(actual_metric).to eq(expected_metric)
      end
    end

    context 'Action and Resource services not aligned' do
      it 'returns .1' do
        statement_hash = {
          'Effect' => 'Allow',
          'Action' => %w[
            fred:YellAtDino
            wilma:YellAtFred
            zeta:BarkAtMoon
            alpha:EatCereal
          ],
          'Resource' => %w[
            arn:aws:fred:us-east-1:3333333333:dino
            arn:aws:wilma:us-east-1:3333333333:dino
            arn:aws:wilma:us-east-1:3333333333:dino
            arn:aws:zebra:us-east-1:3333333333:dino
            arn:aws:alpha:us-east-1:3333333333:dino
            arn:aws:beta:us-east-1:3333333333:dino
          ]
        }
        actual_metric = Statement.new.metric statement_hash
        expected_metric = 7
        expect(actual_metric).to eq(expected_metric)
      end
    end
  end
end