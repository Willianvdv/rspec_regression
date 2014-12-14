require 'spec_helper'
require './lib/rspec_regression'

describe RspecRegression::Analyser do
  let(:base_example) do
    { name: 'base_spec',
      location: 'base_spec.rb',
      sqls: ['SELECT base FROM table'] }
  end

  let(:current_example) do
    { name: 'some_spec',
      location: 'some_spec.rb',
      sqls: ['SELECT 1 FROM table'] }
  end

  let(:previous_example) do
    { 'name' => 'some_spec',
      'location' => 'some_spec.rb',
      'sqls' => ['SELECT 1 FROM table'] }
  end

  let(:previous_results) { [ previous_example ] }
  let(:current_results) { [ current_example ] }

  subject { described_class.new previous_results, current_results }

  describe '.diff_per_example' do
    let(:expected_sqls_in_diff) {}
    let(:expected_diff) do
      [{ name: 'some_spec',
         location: 'some_spec.rb',
         sqls: expected_sqls_in_diff }]
    end

    describe 'the queries are not changed' do
      it 'contains nothing' do
        expect(subject.diff_per_example).to be_empty
      end
    end

    describe 'the current example has an extra query' do
      it 'contains the extra query' do
        current_example[:sqls] << 'SELECT extra FROM table'

        expected_diff.first[:sqls] = { 'meta' => { 'number_of_differences' => 1 },
                                       'plus' => ['SELECT extra FROM table'],
                                       'minus' => [] }

        expect(subject.diff_per_example).to eq(expected_diff)
      end
    end

    describe 'the previous example has an extra query' do
      it 'contains the query that is removed' do
        previous_example['sqls'] << 'SELECT extra FROM table'

        expected_diff.first[:sqls] = { 'meta' => { 'number_of_differences' => 1 },
                                       'plus' => [],
                                       'minus' => ['SELECT extra FROM table'] }

        expect(subject.diff_per_example).to eq(expected_diff)
      end
    end

    describe 'no sql is the same' do
      it 'contains the extra query and the one that is removed' do
        current_example[:sqls] = ['SELECT current FROM table']
        previous_example['sqls'] = ['SELECT previous FROM table']

        expected_diff.first[:sqls] = { 'meta' => { 'number_of_differences' => 0 },
                                       'plus' => ['SELECT current FROM table'],
                                       'minus' => ['SELECT previous FROM table'] }

        expect(subject.diff_per_example).to eq(expected_diff)
      end
    end

    # TODO: Add test when the previous example does not exists
  end
end
