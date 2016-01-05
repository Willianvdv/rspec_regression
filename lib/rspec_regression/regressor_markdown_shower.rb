require 'httparty'

module RspecRegression
  class RegressorMarkdownShower
    def initialize(left_tag, right_tag)
      @left_tag = left_tag
      @right_tag = right_tag
    end

    def show
      puts results
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
      "#{regressor_domain}/api/results/compare_latest_of_tags.text"
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
