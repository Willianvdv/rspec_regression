require 'json'
require 'httparty'

module RspecRegression
  class QueryRegressor
    attr :current_example, :examples

    class << self
      def regressor
        @regressor ||= new
      end

      def start_example(example)
        x = RspecRegression::Example.new(example)
        regressor.start x.slugify(example), example.metadata[:location]
      end

      def end_example
        regressor.end
      end

      def store_and_analyse
        regressor.store_and_analyse
      end
    end

    def initialize
      @sqls = []
      @examples = []
      @subscribed_to_notifications = false
    end

    def start(example_name, example_location)
      subscribe_to_notifications unless @subscribed_to_notifications
      @current_example = { example_name: example_name, example_location: example_location, queries: [] }
    end

    def end
      examples << current_example
      @current_example = nil
    end

    def store
      RegressorStore.new(examples).store
    end

    def add_query(query)
      current_example[:queries] << RspecRegression::Sql.new(query).clean unless current_example.nil?
    end

    private

    def subscribe_to_notifications
      ActiveSupport::Notifications.subscribe "sql.active_record" do |name, started, finished, unique_id, data|
        RspecRegression::QueryRegressor.regressor.add_query data[:sql]
      end

      @subscribed_to_notifications = true
    end
  end

  class RegressorConsoleShower
    def initialize(results)
      @results = results
    end

    def show
      require 'awesome_print'
      puts "\n\n## THE MIGHTY REGRESSOR"

      unless results['results'].empty?
        results['results'].each do |result|
          puts "= Regression detected in: #{result['example_name']} (#{result['example_location']})"
          result['queries_that_got_added'].each do |query|
            puts " (+) #{query}"
          end

          result['queries_that_got_removed'].each do |query|
            puts " (-) #{query}"
          end
        end
      else
        print 'No regressions detected, yeeh!'
      end
    end

    private

    attr_reader :results
  end

  class RegressorStore
    def initialize(examples)
      @examples = examples
    end

    def store
      HTTParty.post regressor_url, body: { result_data: examples }
    end

    private

    attr_reader :examples

    def regressor_domain
      ENV['REGRESSOR_DOMAIN']
    end

    def regressor_url
      "#{regressor_domain}/results"
    end
  end
end
