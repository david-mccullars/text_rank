module TextRank
  ##
  # Rank filters are post-process filters which can filter, enhance, or modify
  # the results of the PageRank algorithm.  A common use case is to collapse highly
  # ranked tokens which are found to be adjacent in the original text.  Other
  # filters might modify the PageRank scores with some sort of external modifier.
  # Another use might be to remove collapsed tokens which are not desired (since
  # token filters only operate on a single, non-collapsed token).
  #
  # Rank filters are applied as a chain, so care should be taken to use them
  # in the desired order.
  ##
  module RankFilter

    autoload :CollapseAdjacent, 'text_rank/rank_filter/collapse_adjacent'

  end
end
