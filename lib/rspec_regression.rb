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

    class << self
      def regressor
        @@regressor ||= new
      end

      def start_example(example)
        description = example.metadata[:description]
        regressor.start description
      end

      def end_example
        regressor.end
      end
    end

    def initialize
      @sqls = []
      @examples = {}
      @subscribed_to_notifications = false
    end

    def start(example_name)
      subscribe_to_notifications unless @subscribed_to_notifications
      @current_example = { name: example_name, sqls: [] }
    end

    def end
      @current_example = nil
    end

    def add_sql(sql)
      @current_example[:sqls] << RspecRegression.Sql.new(sql) unless @current_example.nil?
    end

    # def store_results
    #   File.open('/tmp/current.sqls', 'w') do |file|
    #     file.write @examples.to_json
    #   end
    # end

    def results
      previous_results = JSON.load File.open('/tmp/latest.sqls')

      puts "\n\n\nRegression results:"

      @examples.each do |name, sqls|
        previous_sqls = previous_results[name]
        puts "  - #{name}: \033[1m#{sqls.count}\033[0m / #{previous_sqls.try(:count)}"
      end
    end

    private

    def subscribe_to_notifications
      ActiveSupport::Notifications.subscribe "sql.active_record" do |name, started, finished, unique_id, data|
        self.class.regressor.add_sql data[:sql]
      end

      @subscribed_to_notifications = true
    end
  end
end
