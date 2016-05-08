module TextRank
  ##
  # Token filters can be used to pre-process potential tokens prior to creating
  # a graph or executing PageRank.  Filters are typically used to throw out tokens
  # which are not good candidates for keywords.  However, it is possible for a
  # filter to add new tokens or to modify existing ones.
  #
  # Token filters are applied as a chain, so care should be taken to use them
  # in the desired order.
  ##
  module TokenFilter

    autoload :MinLength,    'text_rank/token_filter/min_length'
    autoload :PartOfSpeech, 'text_rank/token_filter/part_of_speech'
    autoload :Stopwords,    'text_rank/token_filter/stopwords'

  end
end
