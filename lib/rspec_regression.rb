require 'diffy'
require 'active_support'
require "rspec_regression/version"

module RspecRegression
  class Sql
    attr :sql

    def initialize(sql)
      @sql = sql
    end
  end

  class QueryRegressor
    attr :sqls, :examples

    def initialize
      @sqls = []
      @examples = {}
    end

    def result
      puts "\n\nIn this test I detected #{RspecRegression::QueryRegressor.regressor.sqls.count} queries"
    end

    def store
      File.open('/tmp/current.sqls', 'w') do |file|
        file.write @examples.to_json
      end
    end

    def start_example(example_name)
      @current_example = { name: example_name, sqls: [] }
    end

    def end_example
      @examples[@current_example[:name]] = @current_example[:sqls]
    end

    def add_sql(sql)
      @current_example[:sqls] << RspecRegression.Sql.new(sql) unless @current_example.nil?
    end

    def run
      ActiveSupport::Notifications.subscribe "sql.active_record" do |name, started, finished, unique_id, data|
        self.class.regressor.add_sql data[:sql]
      end
    end

    def results
      previous_results = JSON.load File.open('/tmp/latest.sqls')

      puts "\n\n\nRegression results:"

      @examples.each do |name, sqls|
        previous_sqls = previous_results[name]
        puts "  - #{name}: \033[1m#{sqls.count}\033[0m / #{previous_sqls.try(:count)}"
      end
    end

    # CLASS METHOD STUFF

    def self.regressor
      @@regressor ||= new
    end

    def self.start
      FileUtils.mv '/tmp/current.sqls', '/tmp/latest.sqls', force: true if File.file? '/tmp/current.sqls'
      regressor.run
    end

    def self.end
      regressor.store
      regressor.results
      # regressor.result
      # regressor.regression

    end

    def self.start_example(example)
      description = example.metadata[:description]
      regressor.start_example description
    end

    def self.end_example(example)
      regressor.end_example
    end
  end
end
