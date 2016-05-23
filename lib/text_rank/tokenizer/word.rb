module TextRank
  module Tokenizer
    ##
    # A tokenizer regex that preserves a non-space, non-punctuation "word".  It does
    # allow hyphens and numerals, but the first character must be an A-Z character.
    ##
    Word = %r{
      (
        [a-z][a-z0-9-]*
      )
    }xi

  end
end
