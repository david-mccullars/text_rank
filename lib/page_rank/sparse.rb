module PageRank
  ##
  # Implementation of PageRank using a sparse matrix representation of the graph
  #
  # Ruby is not known for its speed, especial for math computations.  However,
  # if the number of edges is relatively small in relation to the number of nodes,
  # this pure Ruby implementation should perform well enough for many applications.
  # It uses a sparse matrix representation and thus avoids an order of mangitude
  # of calculations that are not necessary.
  #
  # If speed is desired, it would be best to implement a NativeSparse class (and
  # optionally NativeDense) which would perform the algorithm in C.
  ##
  class Sparse < Base

    # Initialize with default damping and tolerance.
    # A maximum number of iterations can also be supplied
    # (default is no maximum, i.e. iterate until tolerance).
    # @param (see Base#initialize)
    def initialize(**options)
      super(**options)

      @graph = {}
      @weight_totals = Hash.new(0.0)
      @weights = {}
      @nodes = Set.new
    end

    # @param (see Base#add)
    # @param weight [Float] Optional weight for the graph edge
    # @return (see Base#add)
    def add(source, dest, weight: 1.0)
      return false if source == dest

      @graph[dest] ||= Set.new
      @graph[dest] << source
      @weights[source] ||= Hash.new(0.0)
      @weights[source][dest] += weight
      @weight_totals[source] ||= 0.0
      @weight_totals[source] += weight
      @nodes << source
      @nodes << dest
      nil
    end

    protected

    def node_count
      @nodes.size
    end

    def initial_ranks
      @dangling_nodes = @nodes - @weight_totals.keys
      @normalized_weights = @weights.each_with_object({}) do |(source, values), h|
        h[source] = values.transform_values do |w|
          w / @weight_totals[source]
        end
      end
      Hash[@nodes.map { |k| [k, 1.0 / node_count.to_f] }]
    end

    def calculate_step(ranks)
      ranks.keys.each_with_object({}) do |dest, new_ranks|
        sum = 0.0
        Array(@graph[dest]).each do |source|
          sum += ranks[source] * @normalized_weights[source][dest]
        end
        @dangling_nodes.each do |source|
          sum += ranks[source] / node_count.to_f
        end
        new_ranks[dest] = damping * sum + (1 - damping) / node_count
      end
    end

    def sort_ranks(ranks)
      sum = 0.0
      ranks.each { |_, v| sum += v }
      Hash[ranks.map { |k, v| [k, v / sum] }.sort_by { |_, v| -v }]
    end

    def distance(vector1, vector2)
      super(vector1.values.to_a, vector2.values.to_a)
    end

  end
end
