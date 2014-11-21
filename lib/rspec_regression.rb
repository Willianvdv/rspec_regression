require 'active_support'
require "rspec_regression/version"

module RspecRegression
  class QueryRegressor
    attr :sqls

    def initialize
      @sqls = []
    end

    def result
      puts "\n\nIn this test I detected #{RspecRegression::QueryRegressor.regressor.sqls.count} queries"
    end

    def store
      #sorted_sqls = @sqls.sort
      File.open('/tmp/current.sqls', 'w') { |file| file.write(@sqls.join("\n")) }
    end

    def run
      ActiveSupport::Notifications.subscribe "sql.active_record" do |name, started, finished, unique_id, data|
        self.class.regressor.sqls << data[:sql]
      end
    end

    def self.regressor
      @@regressor ||= new
    end

    def self.start
      FileUtils.mv '/tmp/current.sqls', '/tmp/latest.sqls', force: true if File.file? '/tmp/current.sqls'
      regressor.run
    end

    def self.end
      regressor.result
      regressor.store
    end
  end
end
