module TextRank
  module RankFilter
    ##
    # A rank filter which attempts to collapse one of the highly ranked, single
    # token keywords into a combined keyword when those keywords are adjacent
    # to each other in the original text.
    #
    # = Example
    #
    #  CollapseAdjacent.new(ranks_to_collapse: 6, max_tokens_to_combine: 2).filter!(
    #    {
    #      "town"         => 0.9818754334834477,
    #      "cities"       => 0.9055017128817066,
    #      "siege"        => 0.7411519524982207,
    #      "arts"         => 0.6907977453782612,
    #      "envy"         => 0.6692709808107252,
    #      "blessings"    => 0.6442147897516214,
    #      "plagues"      => 0.5972420789430091,
    #      "florish"      => 0.3746092797528525,
    #      "devoured"     => 0.36867321734332237,
    #      "anxieties"    => 0.3367731719604189,
    #      "peace"        => 0.2905352582752693,
    #      "inhabitants"  => 0.12715120116732137,
    #      "cares"        => 0.0697383057947685,
    #    },
    #    original_text: "cities blessings peace arts florish inhabitants devoured envy cares anxieties plagues town siege"
    #  )
    #  => {
    #   "town siege"        => 0.9818754334834477,
    #   "cities blessings"  => 0.9055017128817066,
    #   "arts florish"      => 0.6907977453782612,
    #   "devoured envy"     => 0.6692709808107252,
    #   "anxieties plagues" => 0.5972420789430091,
    #   "peace"             => 0.2905352582752693,
    #   "inhabitants"       => 0.12715120116732137,
    #   "cares"             => 0.0697383057947685,
    # 
    ##
    class CollapseAdjacent

      # @param ranks_to_collapse [Fixnum] the top N ranks in which to look for collapsable keywords
      # @param max_tokens_to_combine [Fixnum] the maximum number of tokens to collapse into a combined keyword
      # @param ignore_case [true, false] whether to ignore case when finding adjacent keywords in original text
      def initialize(ranks_to_collapse: 10, max_tokens_to_combine: 2, ignore_case: true, **_)
        @ranks_to_collapse = ranks_to_collapse
        @max_tokens_to_combine = max_tokens_to_combine
        @ignore_case = !!ignore_case
      end

      # Perform the filter on the ranks
      # @param ranks [Hash<String, Float>] the results of the PageRank algorithm
      # @param original_text [String] the original text (pre-tokenization) from which to find collapsable keywords
      # @return [Hash<String, Float>]
      def filter!(ranks, original_text:, **_)
        collapsed = {}
        loop do
          permutation = collapse_one(ranks.keys.first(@ranks_to_collapse - collapsed.size), original_text) or break
          collapsed[permutation.join(' ')] = ranks.values_at(*permutation).max
          permutation.each { |token| ranks.delete(token) }
        end
        collapsed.merge!(ranks)
        Hash[collapsed.sort_by { |_, v| -v }]
      end

      private

      def collapse_one(tokens, original_text)
        (2..@max_tokens_to_combine).to_a.reverse_each do |tokens_to_combine|
          tokens.permutation(tokens_to_combine) do |permutation|
            re_options = 0
            re_options |= Regexp::IGNORECASE if @ignore_case
            re = Regexp.new("\\b#{permutation.join(" +")}\\b", re_options)
            return permutation if original_text =~ re
          end
        end
        nil
      end

    end
  end
end
