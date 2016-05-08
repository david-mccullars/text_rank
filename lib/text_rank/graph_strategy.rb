module TextRank
  ##
  # The graph strategy is the heart of the TextRank algorithm.  Strategies
  # determine how a stream of potential tokens are transformed into a graph of
  # unique tokens in such a way that the PageRank algorithm provides meaningful
  # results.
  #
  # The standard TextRank approach uses co-occurence of tokens within a fixed-size
  # window, and that strategy will likely suffice for most applications.  However,
  # there are many variations of TextRank, e.g.:
  #
  # * SingleRank
  # * ExpandRank
  # * ClusterRank
  #
  # @see http://www.hlt.utdallas.edu/~vince/papers/coling10-keyphrase.pdf
  ##
  module GraphStrategy

    autoload :Coocurrence, 'text_rank/graph_strategy/coocurrence'

  end
end
