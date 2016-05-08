module TextRank
  module CharFilter
    ##
    # Character filter to force text to lowercase
    #
    # = Example
    #
    #  Lowercase.new.filter!("What a pessimist you are! - Candide")
    #  => "what a pessimist you are! - candide"
    ##
    class Lowercase

      # Perform the filter
      # @param text [String]
      # @return [String]
      def filter!(text)
        text.downcase!
      end

    end
  end
end
