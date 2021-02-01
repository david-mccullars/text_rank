module PageRank
  class SparseNative < Base

    require 'page_rank/sparse_native.so'

    # @param (see Base#add)
    # @param weight [Float] Optional weight for the graph edge
    # @return (see Base#add)
    def add(source, dest, weight: 1.0)
      _add_edge(source, dest, weight) unless source == dest
    end

    # Perform the PageRank calculation
    # @param max_iterations [Fixnum] Maximum number of PageRank iterations to perform (or -1 for no max)
    # @return [Hash<Object, Float>] of nodes with rank
    def calculate(max_iterations: -1, **_)
      _calculate(max_iterations, damping, tolerance)
    end

  end
end
