module TextRank
  module RankFilter
    ##
    # A rank filter which sorts the results by value
    ##
    class SortByValue

      # @param descending [boolean] whether to sort in descending order
      def initialize(descending: true)
        @descending = !!descending
      end

      # Perform the filter on the ranks
      # @param ranks [Hash<String, Float>] the results of the PageRank algorithm
      # @return [Hash<String, Float>]
      def filter!(ranks, **_)
        Hash[ranks.sort_by { |_, v| @descending ? -v : v }]
      end

    end
  end
end
