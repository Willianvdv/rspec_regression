require 'spec_helper'
require './lib/rspec_regression'

describe RspecRegression::QueryRegressor do
  before do |example|
    @_example = example # cheat
  end

  subject do
    described_class.start_example @_example
    described_class.regressor
  end

  it 'current example name is the name of this spec' do
    current_example = subject.current_example
    expected_name = 'rspecregression_queryregressor_current_example_name_is_the_name_of_this_spec'
    expect(current_example[:name]).to eq expected_name
  end
end
