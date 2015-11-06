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
      examples << current_example.dup
      @current_example = nil
    end

    def add_sql(sql)
      current_example[:sqls] << RspecRegression::Sql.new(sql).clean unless current_example.nil?
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
