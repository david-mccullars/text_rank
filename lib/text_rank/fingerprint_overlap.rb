module TextRank
  ##
  # Determines "overlap" between two fingerprints at each N prefixes
  #
  # For example,
  #
  #   FingerprintOverlap.new(
  #     %w[a b c d],
  #     %w[b e a c],
  #   ).overlap
  #
  #   => [
  #     0, # [a] & (b) have no overlap
  #     1, # [a b] & [b e] have one overlap: b
  #     2, # [a b c] & [b e a] have two overlap: a & b
  #     3, # [a b c d] & [b e a c] have three overlap: a, b, & c
  #   ]
  ##
  class FingerprintOverlap

    attr_reader :overlap

    def initialize(values1, values2)
      raise ArgumentError, 'Value size mismatch' if values1.size != values2.size

      @encountered1 = Set.new
      @encountered2 = Set.new
      @overlap_count = 0

      @overlap = determine_overlap(values1, values2)
    end

    private

    def determine_overlap(values1, values2)
      values1.zip(values2).map do |v1, v2|
        encounter(v1, v2)
        @overlap_count
      end
    end

    # This algorithm is a little more complex than could be represented in Ruby,
    # but we want to keep it as performant as possible.
    def encounter(value1, value2)
      if value1 == value2
        @overlap_count += 1
      else
        # Delete from the set in case an element appears more than once
        @encountered1.delete?(value2) ? (@overlap_count += 1) : (@encountered2 << value2)
        @encountered2.delete?(value1) ? (@overlap_count += 1) : (@encountered1 << value1)
      end
    end

  end
end
