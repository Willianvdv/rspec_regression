require 'hirb'
require 'active_support'
require "rspec_regression/version"

module RspecRegression

  # TODO: Refactor me
  class Example
    def initialize(example)
      @example = example
    end

    def normalize(string)
      string.strip.squeeze(" ").gsub(/[\ :-]+/, '_').gsub(/[\W]/, '').downcase
    end

    def slugify(example)
      parts = [ ]
      metadata = example.metadata

      name = lambda do |metadata|
        description = normalize metadata[:description]
        example_group = if metadata.key?(:example_group)
          metadata[:example_group]
        else
          metadata[:parent_example_group]
        end

        if example_group
          [name[example_group], description].join('_')
        else
          description
        end
      end

      name[example.metadata]
    end
  end

  class Sql
    attr :sql

    def initialize(sql)
      @sql = sql
    end

    def clean
      sql = @sql.strip
      sql = sql.strip.gsub(/\s+/, " ")
      sql
    end
  end

  class QueryRegressor
    attr :current_example, :sqls, :examples

    class << self
      def regressor
        @@regressor ||= new
      end

      def start_example(example)
        x = RspecRegression::Example.new(example)
        regressor.start x.slugify(example), example.metadata[:location]
      end

      def end_example
        regressor.end
      end

      def end
        regressor.store if ENV['REGRESSION_STORE_RESULTS']
        regressor.analyse
      end
    end

    def initialize
      @sqls = []
      @examples = []
      @subscribed_to_notifications = false
    end

    def start(example_name, example_location)
      subscribe_to_notifications unless @subscribed_to_notifications
      @current_example = { name: example_name, location: example_location, sqls: [] }
    end

    def end
      @examples << @current_example
      @current_example = nil
    end

    def add_sql(sql)
      @current_example[:sqls] << RspecRegression::Sql.new(sql).clean unless @current_example.nil?
    end

    def store
      File.open('tmp/sql_regression.sqls', 'w') do |file|
        file.write JSON.pretty_generate(@examples)
      end
    end

    private

    def subscribe_to_notifications
      ActiveSupport::Notifications.subscribe "sql.active_record" do |name, started, finished, unique_id, data|
        RspecRegression::QueryRegressor.regressor.add_sql data[:sql]
      end

      @subscribed_to_notifications = true
    end
  end

  class Analyser
    def initialize(previous_results, current_results)
      @current_results = current_results
      @previous_results = to_hash_with_name_as_key(previous_results)
    end

    def diff
      [].tap do |d|
        @current_results.each do |current_example|
          previous_example = @previous_results[current_example['name']]

          if (sqls_diff = diff_in_example previous_example, current_example)
            d << current_example.merge({'sqls' => sqls_diff })
          end
        end
      end
    end

    private

    def diff_in_example(previous_example, current_example)
      current_sqls = current_example['sqls']
      previous_sqls = @previous_results[current_example['name']]['sqls']

      plus = current_sqls - previous_sqls
      minus = previous_sqls - current_sqls

      { 'plus' => plus, 'minus' => minus } if plus.any? || minus.any?
    end

    def to_hash_with_name_as_key(results)
      Hash[results.map { |example| [example['name'], example] } ]
    end
  end
end
