module TextRank
  module RankFilter
    ##
    # A rank filter which normalizes the ranked keywords so that the sum of the
    # squares of the rank values is 1.0 (and thus the keyword rankings in an
    # N-vector space is a unit vector).
    #
    # = Example
    #
    #  NormalizeUnitVector.new.filter!(
    #    {
    #      "town"         => 0.6818754334834477,
    #      "cities"       => 0.6055017128817066,
    #      "siege"        => 0.5411519524982207,
    #      "arts"         => 0.4907977453782612,
    #      "envy"         => 0.4692709808107252,
    #      "blessings"    => 0.4442147897516214,
    #      "plagues"      => 0.3972420789430091,
    #      "florish"      => 0.2746092797528525,
    #      "devoured"     => 0.26867321734332237,
    #      "anxieties"    => 0.2367731719604189,
    #      "peace"        => 0.1905352582752693,
    #      "inhabitants"  => 0.02715120116732137,
    #    }
    #  )
    #  => {
    #   "town"        => 0.4616807998499129,
    #   "cities"      => 0.40997006401243896,
    #   "siege"       => 0.3664004508761722,
    #   "arts"        => 0.3323068767754191,
    #   "envy"        => 0.317731642948694,
    #   "blessings"   => 0.30076672272820315,
    #   "plagues"     => 0.2689626751964553,
    #   "florish"     => 0.18593107435301526,
    #   "devoured"    => 0.1819119149778339,
    #   "anxieties"   => 0.16031319218415677,
    #   "peace"       => 0.12900665740478157,
    #   "inhabitants" => 0.01838339916101275,
    #  }
    ##
    class NormalizeUnitVector

      # Perform the filter on the ranks
      # @param ranks [Hash<String, Float>] the results of the PageRank algorithm
      # @return [Hash<String, Float>]
      def filter!(ranks, **_)
        return if ranks.empty?
        total = Math.sqrt(ranks.values.map { |v| v * v }.reduce(:+))
        Hash[ranks.map { |k, v| [k, v / total] }]
      end

    end
  end
end
