require 'pry'
require 'spec_helper'
require './lib/rspec_regression'

describe RspecRegression::QueryRegressor do
  before do |example|
    @_example = example # cheat
  end

  let(:fake_query) { 'select * from regressions' }

  def fake_a_notification
    ActiveSupport::Notifications.instrument('sql.active_record', sql: fake_query) do; end
  end

  subject!(:regressor) do
    described_class.start_example @_example
    fake_a_notification
    described_class.regressor
  end

  it 'current example name is the name of this spec' do
    expected_name = 'rspecregression_queryregressor_current_example_name_is_the_name_of_this_spec'
    expect(regressor.current_example[:example_name]).to eq expected_name
  end

  describe 'ending a example' do
    before do
      regressor.end
    end

    it 'stores the results recorded in this example' do
      expect(regressor.examples.last[:queries]).to eq [fake_query]
    end

    it 'resets the example' do
      expect(regressor.current_example).to be_nil
    end
  end

  describe 'end the suite' do
    it 'stores all the examples' do
      VCR.use_cassette('regressor_storage') do
        regressor.end
        regressor.store_and_analyse
      end
    end
  end
end
