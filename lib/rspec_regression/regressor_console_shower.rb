require 'httparty'

module RspecRegression
  class RegressorConsoleShower
    def initialize(left_tag, right_tag)
      @left_tag = left_tag
      @right_tag = right_tag
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

    attr_reader :left_tag, :right_tag

    def results
      @results ||= HTTParty.get regressor_url,
        query: query_parameters,
        headers: headers
    end

    def regressor_domain
      ENV['REGRESSOR_DOMAIN']
    end

    def regressor_url
      "#{regressor_domain}/api/results/compare_latest_of_tags.json"
    end

    def query_parameters
      {
        left_tag: left_tag,
        right_tag: right_tag,
        project_id: project_id,
      }
    end

    def headers
      {
        'AUTHORIZATION' => "Token token=\"#{regressor_api_token}\"",
      }
    end

    def regressor_api_token
      ENV['REGRESSOR_API_TOKEN']
    end

    def project_id
      ENV['REGRESSOR_PROJECT_ID']
    end
  end
end
