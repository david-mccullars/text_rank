module TextRank
  ##
  # Primary class for keyword extraction and hub for filters, tokenizers, and
  # graph strategies # that customize how the text is processed and how the
  # TextRank algorithm is applied.
  #
  # @see README
  ##
  class KeywordExtractor

    # Creates a "basic" keyword extractor with default options
    # @option (see #initialize)
    # @return [KeywordExtractor]
    def self.basic(**options)
      new(**{
        char_filters:   %i[AsciiFolding Lowercase],
        tokenizers:     %i[Word],
        token_filters:  %i[Stopwords MinLength],
        graph_strategy: :Coocurrence,
      }.merge(options))
    end

    # Creates an "advanced" keyword extractor with a larger set of default filters
    # @option (see #initialize)
    # @return [KeywordExtractor]
    def self.advanced(**options)
      new(**{
        char_filters:   %i[AsciiFolding Lowercase StripHtml StripEmail UndoContractions StripPossessive],
        tokenizers:     %i[Url Money Number Word Punctuation],
        token_filters:  %i[PartOfSpeech Stopwords MinLength],
        graph_strategy: :Coocurrence,
        rank_filters:   %i[CollapseAdjacent NormalizeUnitVector SortByValue],
      }.merge(options))
    end

    # @option (see PageRank.new)
    # @option options [Array<Class, Symbol, #filter!>]  :char_filters A list of filters to be applied prior to tokenization
    # @option options [Array<Symbol, Regexp, String>]   :tokenizers A list of tokenizer regular expressions to perform tokenization
    # @option options [Array<Class, Symbol, #filter!>]  :token_filters A list of filters to be applied to each token after tokenization
    # @option options [Class, Symbol, #build_graph]     :graph_strategy A class or strategy instance for producing a graph from tokens
    # @option options [Array<Class, Symbol, #filter!>]  :rank_filters A list of filters to be applied to the keyword ranks after keyword extraction
    def initialize(**options)
      @page_rank_options = {
        strategy:  options[:strategy] || :sparse,
        damping:   options[:damping],
        tolerance: options[:tolerance],
      }
      @char_filters = options[:char_filters] || []
      @tokenizers = options[:tokenizers] || [Tokenizer::Word]
      @token_filters = options[:token_filters] || []
      @rank_filters = options[:rank_filters] || []
      @graph_strategy = options[:graph_strategy] || GraphStrategy::Coocurrence
    end

    # Add a new CharFilter for processing text before tokenization
    # @param filter [Class, Symbol, #filter!] A filter to process text before tokenization
    # @param (see #add_into)
    # @return [nil]
    def add_char_filter(filter, **options)
      add_into(@char_filters, filter, **options)
      nil
    end

    # Add a tokenizer regular expression for producing tokens from filtered text
    # @param tokenizer [Symbol, Regexp, String] Tokenizer regular expression
    # @param (see #add_into)
    # @return [nil]
    def add_tokenizer(tokenizer, **options)
      add_into(@tokenizers, tokenizer, **options)
      nil
    end

    # Sets the graph strategy for producing a graph from tokens
    # @param strategy [Class, Symbol, #build_graph] Strategy for producing a graph from tokens
    # @return [Class, Symbol, #build_graph]
    attr_writer :graph_strategy

    # Add a new TokenFilter for processing tokens after tokenization
    # @param filter [Class, Symbol, #filter!] A filter to process tokens after tokenization
    # @param (see #add_into)
    # @return [nil]
    def add_token_filter(filter, **options)
      add_into(@token_filters, filter, **options)
      nil
    end

    # Add a new RankFilter for processing ranks after calculating
    # @param filter [Class, Symbol, #filter!] A filter to process ranks
    # @param (see #add_into)
    # @return [nil]
    def add_rank_filter(filter, **options)
      add_into(@rank_filters, filter, **options)
      nil
    end

    # Filters and tokenizes text
    # @param text [String] unfiltered text to be tokenized
    # @return [Array<String>] tokens
    def tokenize(text)
      filtered_text = apply_char_filters(text)
      tokens = Tokenizer.tokenize(filtered_text, *tokenizer_regular_expressions)
      apply_token_filters(tokens)
    end

    # Filter & tokenize text, and return PageRank
    # @param text [String,Array<String>] unfiltered text to be processed
    # @return [Hash<String, Float>] tokens and page ranks (in descending order)
    def extract(text, **options)
      text = Array(text)
      tokens_per_text = text.map do |t|
        tokenize(t)
      end
      graph = PageRank.new(**@page_rank_options)
      strategy = classify(@graph_strategy, context: GraphStrategy)
      tokens_per_text.each do |tokens|
        strategy.build_graph(tokens, graph)
      end
      ranks = graph.calculate(**options)
      tokens_per_text.each_with_index do |tokens, i|
        ranks = apply_rank_filters(ranks, tokens: tokens, original_text: text[i])
      end
      ranks
    end

    private

    def apply_char_filters(text)
      @char_filters.reduce(text.clone) do |t, f|
        classify(f, context: CharFilter).filter!(t) || t
      end
    end

    def tokenizer_regular_expressions
      @tokenizers.map do |t|
        case t
        when Symbol
          Tokenizer.const_get(t)
        else
          t
        end
      end
    end

    def apply_token_filters(tokens)
      @token_filters.reduce(tokens) do |t, f|
        classify(f, context: TokenFilter).filter!(t) || t
      end
    end

    def apply_rank_filters(ranks, **options)
      @rank_filters.reduce(ranks) do |t, f|
        classify(f, context: RankFilter).filter!(t, **options) || t
      end
    end

    # @param before [Class, Symbol, Object] item to add before
    # @param at [Fixnum] index to insert new item
    def add_into(array, value, before: nil, at: nil)
      idx = array.index(before) || at || -1
      array.insert(idx, value)
    end

    def classify(clazz, context: self)
      case clazz
      when Class
        clazz.new
      when Symbol
        context.const_get(clazz).new
      else
        clazz
      end
    end

  end
end
