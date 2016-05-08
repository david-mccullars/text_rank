module TextRank
  module CharFilter
    ##
    # Character filter to remove apostrophe from possessives.
    #
    # = Example
    #
    #  StripPosessive.new.filter!("to loathe one’s very being and yet to hold it fast")
    #  => "to loathe one very being and yet to hold it fast"
    ##
    class StripPossessive

      # Perform the filter
      # @param text [String]
      # @return [String]
      def filter!(text)
        text.gsub!(/([a-z]+)'s\b/) do
          $1
        end
      end

    end
  end
end
