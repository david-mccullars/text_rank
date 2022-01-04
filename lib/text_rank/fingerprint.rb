module TextRank
  ##
  # Class used to compare documents according to TextRank. A "fingerprint"
  # represents the first N keywords (in order from most significant to least) from
  # applying the TextRank algorithm.  To compare two "fingerprints" we apply an
  # algorithm that looks at each of the N prefixes and counts the overlap.  This
  # rewards matches of significant keywords much higher than matches of less
  # significant keywords.  But to prevent less significant keywords from being
  # completely ignored we apply an inverse log linear transformation to each of the
  # N prefixes.
  #
  # For example, consider the following comparison:
  #
  #   town man empty found
  #   vs.
  #   general empty found jar
  #
  # The first pass considers just the first keywords: town vs. general.  As these
  # are different, they contribute 0.
  #
  # The second pass considers the first two keywords: town man vs general empty.
  # Again, no overlap, so they contribute 0.
  #
  # The third pass considers the first three keywords: town man empty vs general
  # empty found.  Here we have one overlap: empty. This contributes 1.
  #
  # The fourth pass considers all, and there is two overlaps:  empty & found.  This
  # contributes 2.
  #
  # We can represent the overlaps as the vector [0, 0, 1, 2].  Then we will apply
  # the inverse log linear transformation defined by:
  #
  #   f(x_i) = x_i / ln(i + 1)
  #          = [0, 0, 1 / ln(4), 2 / ln(5)]
  #          = [0, 0, 0.7213475204444817, 1.2426698691192237]
  #
  # Finally we take the average of the transformed vector and normalize it (to
  # ensure a final value between 0.0 and 1.0):
  #
  #   norm(avg(SUM f(x_i))) = norm( avg(1.9640173895637054) )
  #                         = norm( 0.49100434739092635 )
  #                         = 0.49100434739092635 / avg(SUM f(1, 2, 3, 4))
  #                         = 0.49100434739092635 / avg(7.912555793714532)
  #                         = 0.49100434739092635 / 1.978138948428633
  #                         = 0.24821529740414025
  ##
  class Fingerprint

    attr_reader :values, :size

    # Creates a new fingerprint for comparison with another fingerprint
    # @param {Array} values An array of fingerprint values of any hashable type.
    # @return [Fingerprint]
    def initialize(*values)
      @size = values.size
      @values = values
    end

    # Calculates the "similarity" between this fingerprint and another
    # @param {Fingerprint} A second fingerprint to compare
    # @return [Number] A number between 0.0 (different) and 1.0 (same)
    def similarity(other)
      return 1.0 if values == other.values # Short-circuit for efficiency

      sum = 0
      overlap(other).each_with_index do |overlap_value, i|
        sum += overlap_value * linear_transform[i]
      end
      sum
    end

    private

    def overlap(other)
      FingerprintOverlap.new(values, other.values).overlap
    end

    def linear_transform
      @linear_transform ||= size.times.map do |i|
        1.0 / Math.log(i + 2) / size.to_f / norm_factor
      end
    end

    def norm_factor
      @norm_factor ||= size.times.reduce(0.0) do |s, i|
        s + ((i + 1) / Math.log(i + 2) / size.to_f)
      end
    end

  end
end
