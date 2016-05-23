module TextRank
  module Tokenizer
    ##
    # A tokenizer regex that preserves single whitespace characters as a token. Use
    # this if one or more of your TokenFilter classes need whitespace in order to
    # make decisions.
    ##
    Whitespace = %r{\s}

  end
end
