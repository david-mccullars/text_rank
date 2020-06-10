module TextRank
  module TokenFilter
    ##
    # Token filter to remove common stop word tokens
    #
    # = Example
    #
    #   Stopwords.new.filter!(%w[
    #     but for what purpose was the earth formed to drive us mad
    #   ])
    #   => ["purpose", "earth", "formed", "drive", "mad"]
    ##
    class Stopwords

      # Default English stop-word list.
      STOP_WORDS = Set.new(YAML.load_file(File.expand_path('stopwords.yml', __dir__)))

      # Perform the filter
      # @param tokens [Array<String>]
      # @return [Array<String>]
      def filter!(tokens)
        tokens.delete_if do |token|
          STOP_WORDS.include?(token.downcase)
        end
      end

    end
  end
end
