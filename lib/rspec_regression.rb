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
    attr :sqls, :examples

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
      File.open('tmp/sql_regression.sqls', 'w') { |file| file.write JSON.pretty_generate(@examples) }
    end

    def analyse
      too_many_queries

    end

    private

    def too_many_queries
      sql_threshold = (ENV['REGRESSION_QUERY_THRESHOLD'] || 100).to_i
      examples_with_a_lot_of_queries = @examples.keep_if { |example| example[:sqls].count > sql_threshold }
      return unless examples_with_a_lot_of_queries

      examples_with_a_lot_of_queries.sort! { |x, y| x[:sqls].count <=> y[:sqls].count }
      x = examples_with_a_lot_of_queries.map { |x| { number: x[:sqls].count, location: x[:location] } }

      puts "\nExamples with more than #{sql_threshold} queries:"
      puts Hirb::Helpers::AutoTable.render(x)
    end

    def subscribe_to_notifications
      ActiveSupport::Notifications.subscribe "sql.active_record" do |name, started, finished, unique_id, data|
        RspecRegression::QueryRegressor.regressor.add_sql data[:sql]
      end

      @subscribed_to_notifications = true
    end
  end

  # class Analyser
  #   def analyse
  #     @results_json = File.open('tmp/sql_regression.sqls', 'r').read
  #     @results = JSON.parse @results_json
  #
  #     @results.each do |example|
  #       p example['name'] if example['sqls'].count > 100
  #     end
  #
  #     nil
  #   end
  # end
end
