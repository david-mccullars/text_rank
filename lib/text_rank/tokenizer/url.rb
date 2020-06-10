module TextRank
  module Tokenizer

    ##
    # A tokenizer regex that preserves entire URL's as a token (rather than split them up)
    ##
    # rubocop:disable Naming/ConstantName
    Url = %r{
      (
        (?:[\w-]+://?|www[.])
        [^\s()<>]+
        (?:
          \([\w\d]+\)
          |
          (?:[^[:punct:]\s]
          |
          /)
        )
      )
    }xi
    # rubocop:enable Naming/ConstantName

  end
end
