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
  #
  # When tokenizing a piece of text, the Tokenizer will combine one or more
  # regular expressions (in the order given) to scan the text for matches. As such
  # you need only tell the tokenizer which tokens you want; everything else will
  # be ignored.
  ##
  module Tokenizer

    autoload :Money,        'text_rank/tokenizer/money'
    autoload :Number,       'text_rank/tokenizer/number'
    autoload :Punctuation,  'text_rank/tokenizer/punctuation'
    autoload :Url,          'text_rank/tokenizer/url'
    autoload :Whitespace,   'text_rank/tokenizer/whitespace'
    autoload :Word,         'text_rank/tokenizer/word'

    # Performs tokenization of piece of text by one or more tokenizer regular expressions.
    # @param text [String]
    # @param regular_expressions [Array<Regexp|String>]
    # @return [Array<String>]
    def self.tokenize(text, *regular_expressions)
      tokens = []
      text.scan(Regexp.new(regular_expressions.flatten.join('|'))) do |matches|
        m = matches.compact.first
        tokens << m if m&.size&.positive?
      end
      tokens
    end

  end
end
