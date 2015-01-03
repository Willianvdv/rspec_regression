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

  context 'in rails dummy app' do
    let(:env_vars) { { 'AMOUNT_OF_PEOPLES_TO_CREATE' => '10', 'BUNDLE_GEMFILE' => 'Gemfile' } }

    before do
      system(env_vars.merge({'REGRESSION_STORE_RESULTS' => '1' }), "/bin/bash -c 'cd dummy && bundle exec rspec'")
    end

    context 'queries are stable' do
      subject { system(env_vars, "/bin/bash -c 'cd dummy && bundle exec rspec'") }

      it 'x' do
        subject
      end

    end
  end
end
