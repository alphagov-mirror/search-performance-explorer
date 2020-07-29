require "health_check/search_check_result"

module HealthCheck
  SearchCheck = Struct.new(:search_term, :imperative, :path, :minimum_rank, :weight, :tags) do
    def valid_imperative?
      ["should", "should not"].include?(imperative)
    end

    def positive_imperative?
      imperative == "should"
    end

    def valid_path?
      path.present? && path.start_with?("/")
    end

    def valid_search_term?
      search_term.present?
    end

    def valid_weight?
      weight.positive?
    end

    def valid?
      valid_imperative? && valid_path? && valid_search_term? && valid_weight?
    end

    def result(search_results)
      SearchCheckResult.new(check: self, search_results: search_results)
    end

    def uid
      [search_term, path]
    end
  end
end
