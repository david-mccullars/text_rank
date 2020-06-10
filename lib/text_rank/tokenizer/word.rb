module TextRank
  module Tokenizer

    ##
    # A tokenizer regex that preserves a non-space, non-punctuation "word".  It does
    # allow hyphens and numerals, but the first character must be an A-Z character.
    ##
    # rubocop:disable Naming/ConstantName
    Word = /
      (
        [a-z][a-z0-9-]*
      )
    /xi
    # rubocop:enable Naming/ConstantName

  end
end
