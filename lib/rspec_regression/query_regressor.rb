module RspecRegression
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

    def analyse
      unless File.file? 'tmp/sql_regression.sqls'
        puts 'Regression analyse error: `tmp/sql_regression.sqls` could not be found!'
        return
      end

      previous_results_data = File.open('tmp/sql_regression.sqls', 'r')
      previous_results = JSON.parse previous_results_data.read

      analyser = Analyser.new previous_results, @examples
      difference_in_number_of_queries = analyser.difference_in_number_of_queries

      output, status = if difference_in_number_of_queries == 0
        ['Number of queries is stable!', :success]
      elsif difference_in_number_of_queries > 0
        ['Number of queries is increased!', :failure]
      elsif difference_in_number_of_queries < 0
        ['Number of queries is decreased!', :failure]
      end

      puts "\n\n"
      puts '-----------------'
      puts 'Query regression'
      puts '-----------------'
      puts "\nRegression: #{RSpec::Core::Formatters::ConsoleCodes.wrap(output, status)}"





    end

    private

    def subscribe_to_notifications
      ActiveSupport::Notifications.subscribe "sql.active_record" do |name, started, finished, unique_id, data|
        RspecRegression::QueryRegressor.regressor.add_sql data[:sql]
      end

      @subscribed_to_notifications = true
    end
  end
end
