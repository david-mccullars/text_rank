module TextRank
  module Tokenizer
    ##
    # Tokenizer to split on any whitespace
    #
    # = Example
    #
    #  Whitespace.new.tokenize("i should:like to know:which is worse.")
    #  => ["i", "should:like", "to", "know:which", "is", "worse."]
    ##
    class Whitespace < Regex

      def initialize
        super(/\s+/)
      end

    end
  end
end
