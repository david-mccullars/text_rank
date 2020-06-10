module TextRank
  module CharFilter
    ##
    # Characater filter to transform non-ASCII (unicode) characters into ASCII-friendly versions.
    #
    # rubocop:disable Style/AsciiComments
    #
    # = Example
    #
    #  AsciiFolding.new.filter!("the Perigordian Abbé then made answer, because a poor beggar of the country of Atrébatie heard some foolish things said")
    #  => "the Perigordian Abbe then made answer, because a poor beggar of the country of Atrebatie heard some foolish things said"
    #
    # rubocop:enable Style/AsciiComments
    #
    ##
    class AsciiFolding

      # Non-ASCII characters to replace
      NON_ASCII_CHARS        = 'ÀÁÂÃÄÅàáâãäåĀāĂăĄąÇçĆćĈĉĊċČčÐðĎďĐđÈÉÊËèéêëĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħÌÍÎÏìíîïĨĩĪīĬĭĮįİıĴĵĶķĸĹĺĻļĽľĿŀŁłÑñŃńŅņŇňŉŊŋÒÓÔÕÖØòóôõöøŌōŎŏŐőŔŕŖŗŘřŚśŜŝŞşŠšſŢţŤťŦŧÙÚÛÜùúûüŨũŪūŬŭŮůŰűŲųŴŵÝýÿŶŷŸŹźŻżŽž'
      # "Equivalent" ASCII characters
      EQUIVALENT_ASCII_CHARS = 'AAAAAAaaaaaaAaAaAaCcCcCcCcCcDdDdDdEEEEeeeeEeEeEeEeEeGgGgGgGgHhHhIIIIiiiiIiIiIiIiIiJjKkkLlLlLlLlLlNnNnNnNnnNnOOOOOOooooooOoOoOoRrRrRrSsSsSsSssTtTtTtUUUUuuuuUuUuUuUuUuUuWwYyyYyYZzZzZz'

      # Perform the filter
      # @param text [String]
      # @return [String]
      def filter!(text)
        text.tr!(NON_ASCII_CHARS, EQUIVALENT_ASCII_CHARS)
      end

    end
  end
end
