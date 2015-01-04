require 'diff/lcs'

module RspecRegression
  class Analyser
    def initialize(previous_results, current_results)
      @current_results = current_results
      @previous_results = previous_results
      @previous_results_as_hash = to_hash_with_name_as_key(previous_results)
    end

    def difference_in_number_of_queries
      sql_count(@current_results) - sql_count(@previous_results)
    end

    def diff_per_example
      @current_results.map do |current_result|
        previous_result = previous_result_by_name current_result[:name]
        diff = { sqls: diff_in_example(previous_result, current_result) }
        current_result.merge(diff)
      end
    end

    private

    def sql_count(results)
      (results.map { |r| (r[:sqls] || r['sqls']).size }).inject :'+'
    end

    def previous_result_by_name(name)
      @previous_results_as_hash.fetch name, {}
    end

    def diff_in_example(previous_results, current_results)
      current_sqls = current_results[:sqls]
      previous_sqls = previous_results.fetch 'sqls', []
      diff = Diff::LCS.diff(previous_sqls, current_sqls)[0]
      { meta: { number_of_differences: (diff.nil? ? 0 : diff.size) }, diff: diff }
    end

    def to_hash_with_name_as_key(results)
      Hash[results.map { |example| [example['name'], example] } ]
    end
  end
end
