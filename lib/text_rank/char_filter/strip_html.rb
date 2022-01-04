require 'nokogiri'
require 'stringio'

module TextRank
  module CharFilter
    ##
    # Character filter to remove HTML tags and convert HTML entities to text.
    #
    # = Example
    #
    #  StripHtml.new.filter!("&quot;Optimism&quot;, said Cacambo, &quot;What is that?&quot;")
    #  => "\"Optimism\", said Cacambo, \"What is that?\""
    #
    #  StringHtml.new.filter!("<b>Alas! It is the <u>obstinacy</u> of maintaining that everything is best when it is worst.</b>")
    #  => "Alas! It is the obstinacy of maintaining that everything is best when it is worst."
    ##
    class StripHtml < Nokogiri::XML::SAX::Document

      def initialize
        super
        @text = StringIO.new
      end

      # Perform the filter
      # @param text [String]
      # @return [String]
      def filter!(text)
        @text.rewind
        Nokogiri::HTML::SAX::Parser.new(self).parse(text)
        @text.string
      end

      protected

      def characters(string)
        @text << ' '
        @text << string
      end

    end
  end
end
