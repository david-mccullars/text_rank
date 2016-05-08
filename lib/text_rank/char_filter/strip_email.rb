module TextRank
  module CharFilter
    ##
    # Character filter to remove email addresses from text.
    #
    # = Example
    #
    #  StripEmail.new.filter!("That is a hard question said candide@gmail.com")
    #  => "That is a hard question said "
    ##
    class StripEmail

      EMAIL_REGEX = /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/i

      # Perform the filter
      # @param text [String]
      # @return [String]
      def filter!(text)
        text.gsub!(EMAIL_REGEX, '')
      end

    end
  end
end
