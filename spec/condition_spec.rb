require 'iam_complexity_metrics/condition'


describe Condition do
  describe '#metric' do
    context 'zero conditions' do
      it 'returns 0' do
        statement_hash = {
          'Effect' => 'Allow',
          'Action' => 'fred:YellAtDino',
          'Resource' => 'arn:aws:fred:us-east-1:3333333333:dino'
        }
        actual_metric = Condition.new.metric statement_hash
        expected_metric = 0
        expect(actual_metric).to eq(expected_metric)
      end
    end

    context 'two conditions' do
      it 'returns 4' do
        statement_hash = {
          'Effect' => 'Allow',
          'Action' => 'fred:YellAtDino',
          'Resource' => 'arn:aws:fred:us-east-1:3333333333:dino',
          'Condition' => {
            'StringEquals' => {
              'aws:username' => 'johndoe'
            },
            'DateLessThan' => {
              'aws:CurrentTime' => '2019-07-16T15:00:00Z'
            }
          }
        }
        actual_metric = Condition.new.metric statement_hash
        expected_metric = 4
        expect(actual_metric).to eq(expected_metric)
      end
    end

    context 'confusing condition value operators (all)' do
      it 'returns 6' do
        statement_hash = {
          'Effect' => 'Allow',
          'Action' => 'fred:YellAtDino',
          'Resource' => 'arn:aws:fred:us-east-1:3333333333:dino',
          'Condition' => {
            'DateLessThan' => {
              'aws:CurrentTime' => '2019-07-16T15:00:00Z'
            },
            'ForAllValues:StringEquals' => {
              'dynamodb:Attributes' => %w(ID Message Tags)
            }
          }
        }
        actual_metric = Condition.new.metric statement_hash
        expected_metric = 6
        expect(actual_metric).to eq(expected_metric)
      end
    end

    context 'confusing condition value operators (any)' do
      it 'returns 6' do
        statement_hash = {
          'Effect' => 'Allow',
          'Action' => 'fred:YellAtDino',
          'Resource' => 'arn:aws:fred:us-east-1:3333333333:dino',
          'Condition' => {
            'DateLessThan' => {
              'aws:CurrentTime' => '2019-07-16T15:00:00Z'
            },
            'ForAnyValues:StringEquals' => {
              'dynamodb:Attributes' => %w(ID Message Tags)
            }
          }
        }
        actual_metric = Condition.new.metric statement_hash
        expected_metric = 6
        expect(actual_metric).to eq(expected_metric)
      end
    end

    context 'IfExists suffix' do
      it 'returns 3' do
        statement_hash = {
          'Effect' => 'Allow',
          'Action' => 'fred:YellAtDino',
          'Resource' => 'arn:aws:fred:us-east-1:3333333333:dino',
          'Condition' => {
            'StringLikeIfExists' => {
              'ec2:InstanceType' => %w(t1.* t2.* m3.*)
            }
          }
        }
        actual_metric = Condition.new.metric statement_hash
        expected_metric = 3
        expect(actual_metric).to eq(expected_metric)
      end
    end

    context 'Null Condition' do
      it 'returns 3' do
        statement_hash = {
          'Effect' => 'Allow',
          'Action' => 'fred:YellAtDino',
          'Resource' => 'arn:aws:fred:us-east-1:3333333333:dino',
          'Condition' => {
            'Null' => {
              'aws:TokenIssueTime' =>'true'
            }
          }
        }
        actual_metric = Condition.new.metric statement_hash
        expected_metric = 3
        expect(actual_metric).to eq(expected_metric)
      end
    end

    context 'Policy tags' do
      it 'returns 3' do
        statement_hash = {
          'Effect' => 'Allow',
          'Action' => 'fred:YellAtDino',
          'Resource' => 'arn:aws:fred:us-east-1:3333333333:dino',
          'Condition' => {
            'StringLike' => {
              'sns:endpoint' => 'https://example.com/${aws:username}/*'
            }
          }
        }
        actual_metric = Condition.new.metric statement_hash
        expected_metric = 3
        expect(actual_metric).to eq(expected_metric)
      end
    end

    context 'Policy tags in an array' do
      it 'returns 3' do
        statement_hash = {
          'Effect' => 'Allow',
          'Action' => 'fred:YellAtDino',
          'Resource' => 'arn:aws:fred:us-east-1:3333333333:dino',
          'Condition' => {
            'ForAnyValues:StringEquals' => {
              'dynamodb:Attributes' => %w(ID ${aws:username} Tags)
            }
          }
        }
        actual_metric = Condition.new.metric statement_hash
        expected_metric = 5
        expect(actual_metric).to eq(expected_metric)
      end
    end

    context 'Escaped Policy tags' do
      it 'returns 3' do
        statement_hash = {
          'Effect' => 'Allow',
          'Action' => 'fred:YellAtDino',
          'Resource' => 'arn:aws:fred:us-east-1:3333333333:dino',
          'Condition' => {
            'StringLike' => {
              'sns:endpoint' => 'https://example.com/${$}fred/*'
            }
          }
        }
        actual_metric = Condition.new.metric statement_hash
        expected_metric = 2
        expect(actual_metric).to eq(expected_metric)
      end
    end
  end
end
