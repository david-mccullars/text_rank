module TextRank
  module Tokenizer
    ##
    # A tokenizer that preserves punctuation as their own tokens (which can be
    # used, for example, by the [TokenFilter::PartOfSpeechBase] filter).
    #
    # = Example
    #
    #  WordsAndPunctuation.new.tokenize("i should:like to know:which is worse.")
    #  => ["i", "should", ":", "like", "to", "know", ":", "which", "is", "worse", "."]
    ##
    class WordsAndPunctuation < Regex

      def initialize
        super(/
          ([a-z][a-z0-9-]+)
          |
          ([\p{Punct}])
          |
          \s+
        /xi)
      end

    end
  end
end
