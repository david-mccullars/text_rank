module TextRank
  ##
  # Tokenizers are responsible for transforming a single String of text into an
  # array of potential keywords ("tokens").  There are no requirements of tokens
  # other than to be non-empty.  When used in combination with token filters, it
  # may make sense for a tokenizer to temporarily create tokens which might seem
  # like ill-suited keywords.  The token filter may use these "bad" keywords to
  # help inform its decision on which tokens to keep and which to drop.  An example
  # of this is the part of speech token filter which uses punctuation tokens to
  # help guess the part of speech of each non-punctuation token.
  ##
  module Tokenizer

    autoload :Regex,                'text_rank/tokenizer/regex'
    autoload :Whitespace,           'text_rank/tokenizer/whitespace'
    autoload :WordsAndPunctuation,  'text_rank/tokenizer/words_and_punctuation'

  end
end
