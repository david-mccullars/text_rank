##
# A module for supporting Ruby implementations of PageRank. Rather than rely on
# one single implementation, this module allows for multiple implementations that
# may be beneficial in different scenarios.
#
# = Example
#
#   PageRank.calculate(strategy: :dense, damping: 0.8, max_iterations: 100) do
#     add('nodeA', 'nodeC', weight: 4.3)
#     add('nodeA', 'nodeE', weight: 2.1)
#     add('nodeB', 'nodeC', weight: 3.6)
#     add('nodeE', 'nodeD', weight: 1.9)
#     add('nodeA', 'nodeC', weight: 5.3)
#   end
##
module PageRank

  autoload :Base,   'page_rank/base'
  autoload :Dense,  'page_rank/dense'
  autoload :Sparse, 'page_rank/sparse'

  # @option options [Symbol] :strategy PageRank strategy to use (either :sparse or :dense)
  # @option options [Float]  :damping The probability of following the graph vs. randomly choosing a new node
  # @option options [Float]  :tolerance The desired accuracy of the results
  # @return [PageRank::Base]
  def self.new(strategy: :sparse, **options)
    const_get(strategy.to_s.capitalize).new(**options)
  end

  # Convenience method to quickly calculate PageRank. In the calling block, graph edges can be added.
  # @option (see new)
  # @return (see Base#calculate)
  def self.calculate(**options, &block)
    pr = new(**options)
    pr.instance_exec(&block)
    pr.calculate(**options)
  end

end
