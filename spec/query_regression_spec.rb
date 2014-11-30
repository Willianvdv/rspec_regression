require 'spec_helper'
require './lib/rspec_regression'

describe RspecRegression::QueryRegressor do
  it 'starts query regressor' do
    described_class.start_example nil
  end
end
