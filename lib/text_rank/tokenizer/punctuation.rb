module TextRank
  module Tokenizer

    ##
    # A tokenizer regex that preserves single punctuation symbols as a token. Use
    # this if one or more of your TokenFilter classes need punctuation in order to
    # make decisions.
    ##
    # rubocop:disable Naming/ConstantName
    Punctuation = /(\p{Punct})/
    # rubocop:enable Naming/ConstantName

  end
end
