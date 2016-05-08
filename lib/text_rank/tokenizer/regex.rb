module TextRank
  module Tokenizer
    ##
    # Base tokenizer that tokenizes on any regular expression
    #
    # = Example
    #
    #  Regex.new(/:/).tokenize("i should:like to know:which is worse.")
    #  => ["i should", "like to know", "which is worse"]
    ##
    class Regex

      # @param regex [Regexp] to use for string splitting
      def initialize(regex)
        @regex = regex
      end

      # @param text [String] string to tokenize
      # return [Array<String>] non-empty tokens
      def tokenize(text)
        text.split(@regex) - ['']
      end

    end
  end
end
