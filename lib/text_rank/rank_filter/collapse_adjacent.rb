module TextRank
  module RankFilter
    ##
    # A rank filter which attempts to collapse one of the highly ranked, single
    # token keywords into a combined keyword when those keywords are adjacent
    # to each other in the original text.
    #
    # It tries to do this in as intelligent a manner as possible, keeping the single
    # tokens that comprise a combination when one or more of the single tokens occur
    # more often than the combination.
    #
    # This filter operates on the original (non-filtered) text in order to more
    # intelligently determine true text adjacency versus token adjacency (e.g.
    # two tokens can be adjacent even though they appeared in the original text
    # on separate lines with punctuation in between.  However, because it operates
    # on the original text we may fail to find some combinations due to the
    # keyword tokens not exactly matching the original text any more (e.g. if
    # ASCII folding has occurred).  The goal is to err on the side of caution:
    # it is better to not suggest a combination than to suggest a bad combination.
    #
    # = Example
    #
    #  CollapseAdjacent.new(ranks_to_collapse: 6, max_tokens_to_combine: 2).filter!(
    #    {
    #      "town"         => 0.9818754334834477,
    #      "cities"       => 0.9055017128817066,
    #      "siege"        => 0.7411519524982207,
    #      "arts"         => 0.6907977453782612,
    #      "envy"         => 0.6692709808107252,
    #      "blessings"    => 0.6442147897516214,
    #      "plagues"      => 0.5972420789430091,
    #      "florish"      => 0.3746092797528525,
    #      "devoured"     => 0.36867321734332237,
    #      "anxieties"    => 0.3367731719604189,
    #      "peace"        => 0.2905352582752693,
    #      "inhabitants"  => 0.12715120116732137,
    #      "cares"        => 0.0697383057947685,
    #    },
    #    original_text: "cities blessings peace arts florish inhabitants devoured envy cares anxieties plagues town siege"
    #  )
    #  => {
    #   "town siege"        => 0.9818754334834477,
    #   "cities blessings"  => 0.9055017128817066,
    #   "arts florish"      => 0.6907977453782612,
    #   "devoured envy"     => 0.6692709808107252,
    #   "anxieties plagues" => 0.5972420789430091,
    #   "peace"             => 0.2905352582752693,
    #   "inhabitants"       => 0.12715120116732137,
    #   "cares"             => 0.0697383057947685,
    #   "town siege"        => 0.2365184450186848,
    #   "cities blessings"  => 0.21272821337880285,
    #   "arts florish"      => 0.146247479840506,
    #   "devoured envy"     => 0.1424776818760168,
    #   "anxieties plagues" => 0.12821144722639122,
    #   "peace"             => 0.07976303576999531,
    #   "inhabitants"       => 0.03490786580297893,
    #   "cares"             => 0.019145831086624026,
    #  }
    ##
    class CollapseAdjacent

      # @option options [Fixnum] ranks_to_collapse the top N ranks in which to look for collapsable keywords
      # @option options [Fixnum] max_tokens_to_combine the maximum number of tokens to collapse into a combined keyword
      # @option options [true, false] ignore_case whether to ignore case when finding adjacent keywords in original text
      # @option options [String] delimiter an optional delimiter between adjacent keywords in original text
      def initialize(**options)
        @options = options
      end

      # Perform the filter on the ranks
      # @param ranks [Hash<String, Float>] the results of the PageRank algorithm
      # @param original_text [String] the original text (pre-tokenization) from which to find collapsable keywords
      # @return [Hash<String, Float>]
      def filter!(ranks, original_text:, **_)
        TokenCollapser.new(tokens: ranks, text: original_text, **@options).collapse
      end

      class TokenCollapser

        # rubocop:disable Metrics/ParameterLists
        def initialize(tokens:, text:, ranks_to_collapse: 10, max_tokens_to_combine: 2, ignore_case: true, delimiter: ' ', **_)
          @tokens = tokens
          @text = text

          @ranks_to_collapse = ranks_to_collapse
          @max_tokens_to_combine = max_tokens_to_combine
          @ignore_case = !!ignore_case
          @delimiter = delimiter.to_s == '' ? ' ' : delimiter

          @to_collapse = Set.new # Track the permutations we plan to collapse
          @to_remove = Set.new # Track the single tokens we plan to remove (due to being collapsed)
          @permutations_scanned = Hash.new(0.0) # Track how many occurrences of each permutation we found in the original text
          @combination_significance_threshold = 0.3 # The percent of occurrences of a combo of tokens to the occurrences of single tokens required to force collapsing
        end
        # rubocop:enable Metrics/ParameterLists

        # :nodoc:
        def delimiter_re
          @delimiter_re ||= /#{@delimiter}+/
        end

        # :nodoc:
        def collapse
          # We make multiple passes at collapsing because after the first pass we may have
          # replaced two or more singletons with a collapsed token, bumping up one or more
          # single tokens from below the cut to above it.  So we'll continue searching
          # until all of the top N final keywords (single or collapsed) have been
          # considered.
          while collapse_attempt
            # keep trying
          end

          # We now know what to collapse and what to remove, so we can start safely
          # modifying the tokens hash
          apply_collapse
        end

        # :nodoc:
        def collapse_attempt
          regexp_safe_tokens = @tokens.keys.select { |s| Regexp.escape(s) == s }
          single_tokens_to_consider = regexp_safe_tokens.first(@ranks_to_collapse + @to_remove.size - @to_collapse.size) - @to_remove.to_a
          scan_text_for_all_permutations_of(single_tokens_to_consider) or return false
          decide_what_to_collapse_and_what_to_remove
          true
        end

        # :nodoc:
        def apply_collapse
          @to_collapse.each do |perm|
            values = @tokens.values_at(*perm).compact
            # This might be empty if somehow the scanned permutation doesn't
            # exactly match one of the tokens (e.g. ASCII-folding gone awry).
            # The goal is to do the best we can, so if we can't find it, ignore.
            next if values.empty?

            @tokens[perm.join(@delimiter)] = values.reduce(:+) / values.size
          end

          @tokens.reject! do |k, _|
            @to_remove.include?(k)
          end || @tokens
        end

        # We need to be efficient about how we search for the large number of possible collapsed keywords.
        # Doing them one at a time is very expensive and performs at least 20 times slower in my tests.
        # And since we do multiple passes we need to be careful about not searching for the same combo
        # more than once.  So for every combo (and the single tokens themselves) we've searched for we
        # keep track of the number of times we've found them.
        #
        # Even for single tokens this may be zero due to some modification from the original text before
        # tokenization (e.g. ASCII folding).  That's okay.  We're just making the best effort we can
        # to find what we can.
        def scan_text_for_all_permutations_of(single_tokens)
          # NOTE: that by reversing the order we craft the regex to prefer larger combinations over
          # smaller combinations (or singletons).
          perms = (1..@max_tokens_to_combine).to_a.reverse.flat_map do |n|
            scan_text_for_n_permutations_of(single_tokens, n)
          end
          scan_text_for(perms) do |s|
            s = s.downcase if @ignore_case
            @permutations_scanned[s.split(delimiter_re)] += 1
          end unless perms.empty?
        end

        def scan_text_for_n_permutations_of(single_tokens, n_perms)
          single_tokens.permutation(n_perms).map do |perm|
            unless @permutations_scanned.key?(perm)
              @permutations_scanned[perm] = 0
              perm
            end
          end.compact
        end

        # Because we're scanning the original text, we've lost all of the character filtering we did
        # prior to tokenization, but that's important because we need the original context to be more
        # choosy.  Still, we need to know what delimiter goes between collapsed tokens (since it may
        # not always be a space).  Likewise, we can't always assume the Lowercase filter has been
        # used, so we allow for customziation with the :ignore_case & :delimiter options.
        def scan_text_for(all)
          flags = 0
          flags |= Regexp::IGNORECASE if @ignore_case
          searches = all.map do |a|
            a.is_a?(Array) ? a.join(delimiter_re.to_s) : a
          end
          re = Regexp.new("\\b(#{searches.join('|')})\\b", flags)

          any_found = false
          @text.scan(re) do |s, _|
            yield s
            any_found = true
          end
          any_found
        end

        # Once we have the number of occurrences for every permutation (including singletons)
        # we can make choices about what to collapse and what to remove.  We won't make any
        # modifications to the original token list yet but just keep track of what we plan
        # to collapse/remove.
        def decide_what_to_collapse_and_what_to_remove
          tokens_encountered = []
          permutations_to_consider_collapsing.each do |perm, perm_count|
            if perm.size > 1
              decide_to_collapse_or_remove(perm, perm_count, singles_to_remove: perm - tokens_encountered)
            end
            tokens_encountered += perm
          end
        end

        def permutations_to_consider_collapsing
          @permutations_scanned.select do |_k, v|
            v.positive?
          end.sort_by do |k, v|
            [-v, -k.size] # reverse order
          end
        end

        def decide_to_collapse_or_remove(perm, perm_count, singles_to_remove:)
          if !singles_to_remove.empty? || combination_significant?(perm, perm_count)
            @to_collapse << perm if perm.size > 1
            @to_remove |= singles_to_remove
          end
        end

        # Even if we encounter a potential collapsed key which occurs less often than the single tokens that make it up,
        # we still want to add the collapsed key if it shows up "enough" times.
        def combination_significant?(perm, perm_count)
          total_single_count = perm.reduce(0) { |s, t| s + @permutations_scanned[[t]] } / perm.size.to_f
          total_single_count.zero? || (perm_count / total_single_count) > @combination_significance_threshold
        end

      end

      private_constant :TokenCollapser

    end
  end
end
