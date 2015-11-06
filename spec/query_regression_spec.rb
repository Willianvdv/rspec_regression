require 'pry'
require 'spec_helper'
require './lib/rspec_regression'

describe RspecRegression::QueryRegressor do
  before do |example|
    @_example = example # cheat
  end

  subject!(:regressor) do
    described_class.start_example @_example
    described_class.regressor
  end

  it 'current example name is the name of this spec' do
    expected_name = 'rspecregression_queryregressor_current_example_name_is_the_name_of_this_spec'
    expect(regressor.current_example[:name]).to eq expected_name
  end

  describe 'ending a example' do
    it 'stores the results recorded in this example' do
      fake_query = 'select * from regressions'
      ActiveSupport::Notifications.instrument('sql.active_record', sql: fake_query) do; end

      regressor.end
      expect(regressor.examples.last[:sqls]).to eq [fake_query]
    end

    it 'resets the example' do
      regressor.end
      expect(regressor.current_example).to be_nil
    end
  end
end
