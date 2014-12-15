module RspecRegression
  class Analyser
    def initialize(previous_results, current_results)
      @current_results = current_results
      @previous_results = previous_results
      @previous_results_as_hash = to_hash_with_name_as_key(previous_results)
    end

    def difference_in_number_of_queries
      current_number_of_queries = (@current_results.map { |example| example[:sqls].size }).inject :'+'
      previous_number_of_queries = (@previous_results.map { |example| example['sqls'].size }).inject :'+'

      current_number_of_queries - previous_number_of_queries
    end

    def diff_per_example
      [].tap do |d|
        @current_results.each do |current_example|
          previous_example = @previous_results_as_hash.fetch current_example[:name], {}

          if (sqls_diff = diff_in_example previous_example, current_example)
            d << current_example.merge({ sqls: sqls_diff })
          end
        end
      end
    end

    private

    def diff_in_example(previous_example, current_example)
      current_sqls = current_example[:sqls]
      previous_sqls = previous_example.fetch 'sqls', []

      plus = current_sqls - previous_sqls
      minus = previous_sqls - current_sqls

      number_of_differences = (current_sqls.size - previous_sqls.size).abs

      if plus.any? || minus.any?
        { 'meta' => { 'number_of_differences' => number_of_differences },
        'plus' => plus,
        'minus' => minus }
      end
    end

    def to_hash_with_name_as_key(results)
      Hash[results.map { |example| [example['name'], example] } ]
    end
  end
end
