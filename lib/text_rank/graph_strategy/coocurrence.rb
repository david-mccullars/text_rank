module TextRank
  module GraphStrategy
    ##
    # The original TextRank algorithm uses co-occurrence in determining how to
    # construct a graph of eligible token keywords and relate them together.  Given a
    # window size of N any other token at most N positions away from a token is
    # considered co-ocurrent, and an edge will be drawn between them.
    #
    # This implementation makes a slight change from the original algorithm by
    # choosing a weight of 1/distance_from_token as the edge weight.
    #
    # = Example
    #   Coocurrence.new(ngram_size: 4).build_graph(%w[what a pessimist you are exclaimed candide], graph)
    #   # graph.add("what", "a", 1.0)
    #   # graph.add("what", "pessimist", 0.5)
    #   # graph.add("what", "you", 0.3333333333333333)
    #   # graph.add("what", "are", 0.25)
    #   # graph.add("a", "what", 1.0)
    #   # graph.add("a", "pessimist", 1.0)
    #   # graph.add("a", "you", 0.5)
    #   # graph.add("a", "are", 0.3333333333333333)
    #   # graph.add("a", "exclaimed", 0.25)
    #   # graph.add("pessimist", "what", 0.5)
    #   # graph.add("pessimist", "a", 1.0)
    #   # graph.add("pessimist", "you", 1.0)
    #   # graph.add("pessimist", "are", 0.5)
    #   # graph.add("pessimist", "exclaimed", 0.3333333333333333)
    #   # graph.add("pessimist", "candide", 0.25)
    #   # graph.add("you", "what", 0.3333333333333333)
    #   # graph.add("you", "a", 0.5)
    #   # graph.add("you", "pessimist", 1.0)
    #   # graph.add("you", "are", 1.0)
    #   # graph.add("you", "exclaimed", 0.5)
    #   # graph.add("you", "candide", 0.3333333333333333)
    #   # graph.add("are", "what", 0.25)
    #   # graph.add("are", "a", 0.3333333333333333)
    #   # graph.add("are", "pessimist", 0.5)
    #   # graph.add("are", "you", 1.0)
    #   # graph.add("are", "exclaimed", 1.0)
    #   # graph.add("are", "candide", 0.5)
    #   # graph.add("exclaimed", "a", 0.25)
    #   # graph.add("exclaimed", "pessimist", 0.3333333333333333)
    #   # graph.add("exclaimed", "you", 0.5)
    #   # graph.add("exclaimed", "are", 1.0)
    #   # graph.add("exclaimed", "candide", 1.0)
    #   # graph.add("candide", "pessimist", 0.25)
    #   # graph.add("candide", "you", 0.3333333333333333)
    #   # graph.add("candide", "are", 0.5)
    #   # graph.add("candide", "exclaimed", 1.0)
    ##
    class Coocurrence

      # @param ngram_size [Fixnum] Window size around a token considered co-occurrence
      def initialize(ngram_size: 3, **_)
        @ngram_size = ngram_size
      end

      # Build a graph for which the PageRank algorithm will be applied
      # @param tokens [Array<String>] filtered tokens from which to build a graph
      # @param graph [PageRank::Base] a PageRank graph into which to add nodes/edges
      # return [nil]
      def build_graph(tokens, graph)
        ngram_window = @ngram_size * 2 + 1
        tokens.each_with_index do |token_i, i|
          ngram_window.times do |j|
            next if j == @ngram_size || i + j < @ngram_size
            token_j = tokens[i - @ngram_size + j]
            if token_j
              graph.add(token_i, token_j, weight: 1.0 / (j - @ngram_size).abs)
            end
          end
        end
        nil
      end

    end
  end
end
