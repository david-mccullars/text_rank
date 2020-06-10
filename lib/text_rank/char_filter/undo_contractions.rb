module TextRank
  module CharFilter
    ##
    # Character filter to convert English contractions into their expanded form.
    #
    # = Example
    #
    #  UndoContractions.new.filter!("You're a bitter man. That's because I've lived.")
    #  => "You are a bitter man. That is because I have lived."
    ##
    class UndoContractions

      # List of English contractions to undo
      CONTRACTIONS = YAML.load_file(File.expand_path('undo_contractions.yml', __dir__))

      # Perform the filter
      # @param text [String]
      # @return [String]
      def filter!(text)
        text.gsub!(/[a-z']+/) do |word|
          CONTRACTIONS[word] || word
        end
      end

    end
  end
end
