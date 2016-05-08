module PageRank
  ##
  # A base class for PageRank implementations.  This class provides the basic
  # framework for adding (optionall weighted) nodes to the graph and then
  # performing iterations of PageRank to within the desired tolerance (or maximum
  # allowed number of iterations).
  ##
  class Base

    # @param (see #damping=)
    # @param (see #tolerance=)
    def initialize(damping: nil, tolerance: nil, **_)
      self.damping = damping
      self.tolerance = tolerance
    end

    # Set the damping probability
    # @param damping [Float] The probability of following the graph vs. randomly choosing a new node
    # @return [Float]
    def damping=(damping)
      @damping = damping || 0.85
      raise ArgumentError.new('Invalid damping factor') if @damping <= 0 || @damping > 1
      @damping
    end

    # Set the tolerance value
    # @param tolerance [Float] The desired accuracy of the results
    # @return [Float]
    def tolerance=(tolerance)
      @tolerance = tolerance || 0.0001
      raise ArgumentError.new('Invalid tolerance factor') if @tolerance < 0 || @tolerance > 1
      @tolerance
    end

    # Adds a directed (and optionally weighted) edge to the graph
    # @param source [Object] The source node
    # @param dest [Object] The destination node
    # @return [nil]
    def add(_source, _dest, **_options)
      raise NotImplementedError
    end

    # Perform the PageRank calculation
    # @param max_iterations [Fixnum] Maximum number of PageRank iterations to perform (or -1 for no max)
    # @return [Hash<Object, Float>] of nodes with rank
    def calculate(max_iterations: -1, **_)
      ranks = initial_ranks
      loop do
        break if max_iterations == 0
        ranks, prev_ranks = calculate_step(ranks), ranks
        break if distance(ranks, prev_ranks) < @tolerance
        max_iterations -= 1
      end
      sort_ranks(ranks)
    end

    protected

    # Should return the number of nodes in the graph
    def node_count
      raise NotImplementedError
    end

    # Should produce the initial ranks from which to start the first PageRank iteration
    def initial_ranks
      raise NotImplementedError
    end

    # Should apply any sort of sorting logic to the result rankings after PageRank has finished
    def sort_ranks(_ranks)
      raise NotImplementedError
    end

    # Performs a single step of the PageRank iteration
    def calculate_step(_ranks)
      raise NotImplementedError
    end

    # Calculate the Euclidean distance from one ranking to the next iteration
    def distance(v1, v2)
      sum_squares = node_count.times.reduce(0.0) do |sum, i|
        d = v1[i] - v2[i]
        sum + d * d
      end
      Math.sqrt(sum_squares)
    end

  end
end
