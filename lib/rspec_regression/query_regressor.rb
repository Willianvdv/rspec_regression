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

      def store
        regressor.store
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
      ENV.fetch 'REGRESSOR_DOMAIN', 'http://regressor.herokuapp.com'
    end

    def regressor_project_id
      ENV['REGRESSOR_PROJECT_ID']
    end

    def regressor_url
      "#{regressor_domain}/results?project_id=#{regressor_project_id}"
    end
  end
end
