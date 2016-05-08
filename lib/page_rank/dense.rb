require 'matrix'

module PageRank
  ##
  # Implementation of PageRank using matrix multiplication
  #
  # Ruby is not known for its speed, especial for math computations.  As such this
  # implementation is not well suited for large graphs, and it is especially not
  # well suited for graphs that have a small edge-to-vertex ratio.  The primary
  # purpose of this implementation is to provide a checkpoint against other
  # implementations to verify their validity.
  #
  # If speed is desired, it would be best to implement a NativeDense class (and
  # optionally NativeSparse) which would perform the algorithm in C.
  ##
  class Dense < Base

    # Initialize with default damping and tolerance.
    # A maximum number of iterations can also be supplied
    # (default is no maximum, i.e. iterate until tolerance).
    # @param (see Base#initialize)
    def initialize(**options)
      super(**options)

      @out_links = []
      @key_to_idx = {}
      @idx_to_key = {}
    end

    # @param (see Base#add)
    # @param weight [Float] Optional weight for the graph edge
    # @return (see Base#add)
    def add(source, dest, weight: 1.0)
      return if source == dest
      source_idx = index(source)
      dest_idx = index(dest)
      @out_links[source_idx] ||= []
      @out_links[source_idx][dest_idx] ||= 0.0
      @out_links[source_idx][dest_idx] += weight
      nil
    end

    protected

    def node_count
      @key_to_idx.size
    end

    def initial_ranks
      @matrix = to_matrix
      Vector[*[1 / node_count.to_f] * node_count]
    end

    def calculate_step(ranks)
      @matrix * ranks
    end

    def sort_ranks(ranks)
      ranks.each_with_index.sort_by { |r, _| -r }.each_with_object({}) do |(r, i), all|
        all[@idx_to_key[i]] = r
      end
    end

    private

    def index(key)
      @key_to_idx[key] ||= begin
        @idx_to_key[node_count] = key
        node_count
      end
    end

    def to_matrix
      total_out_weights = @out_links.map do |links|
        links.compact.reduce(:+) if links
      end
      Matrix.build(node_count, node_count) do |dest_idx, source_idx|
        total = total_out_weights[source_idx]
        if total
          w = @out_links[source_idx][dest_idx] || 0.0
          @damping * w / total + (1 - @damping) / node_count.to_f
        else
          1.0 / node_count.to_f
        end
      end
    end

  end
end
