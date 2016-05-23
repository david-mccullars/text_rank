module TextRank
  module RankFilter
    ##
    # A rank filter which normalizes the ranked keywords so that the sum of the
    # rank values is 1.0 (a "probability" normalization).
    #
    # = Example
    #
    #  NormalizeProbability.new.filter!(
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
    #   "town"        => 0.1473434248897056,
    #   "cities"      => 0.13084016782478722,
    #   "siege"       => 0.11693511476062682,
    #   "arts"        => 0.10605429845557579,
    #   "envy"        => 0.10140267579486278,
    #   "blessings"   => 0.09598839508602595,
    #   "plagues"     => 0.08583827125543537,
    #   "florish"     => 0.0593390959673909,
    #   "devoured"    => 0.058056398684529435,
    #   "anxieties"   => 0.051163259981992296,
    #   "peace"       => 0.041171915188530236,
    #   "inhabitants" => 0.005866982110537665,
    #  }
    ##
    class NormalizeProbability

      # Perform the filter on the ranks
      # @param ranks [Hash<String, Float>] the results of the PageRank algorithm
      # @return [Hash<String, Float>]
      def filter!(ranks, **_)
        return if ranks.empty?
        total = ranks.values.reduce(:+)
        Hash[ranks.map { |k, v| [k, v / total] }]
      end

    end
  end
end
