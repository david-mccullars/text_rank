require 'engtagger'

module TextRank
  module TokenFilter
    ##
    # Token filter to keep only a selected set of parts of speech
    #
    # = Example
    #
    #   PartOfSpeech.new(parts_to_keep: %w[nn nns]).filter!(%w[
    #     all men are by nature free
    #   ])
    #   => ["men", "nature"]
    ##
    class PartOfSpeech

      # @param parts_to_keep [Array<String>] list of engtagger parts of speech to keep
      # @see https://github.com/yohasebe/engtagger#tag-set
      def initialize(parts_to_keep: %w[nn nnp nnps nns jj jjr jjs vb vbd vbg vbn vbp vbz], **_)
        @parts_to_keep = Set.new(parts_to_keep)
        @eng_tagger = EngTagger.new
        @last_pos_tag = 'pp'
      end

      # Perform the filter
      # @param tokens [Array<String>]
      # @return [Array<String>]
      def filter!(tokens)
        tokens.keep_if do |token|
          @parts_to_keep.include?(pos_tag(token))
        end
      end

      private

      def pos_tag(token)
        tag = @eng_tagger.assign_tag(@last_pos_tag, token) rescue nil
        tag = 'nn' if tag.nil? || tag == ''
        @last_pos_tag = tag
      end

    end
  end
end
