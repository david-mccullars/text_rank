$LOAD_PATH << 'lib'
require 'text_rank'
pr = PageRank::SparseNative.new
pr.add("N0", "N1", weight: 0.612)
pr.add("N2", "N1", weight: 0.492)
pr.add("N2", "N0", weight: 0.67)
p pr.calculate


puts "....................................."
puts "....................................."
puts "....................................."



pr = PageRank::Sparse.new
pr.add("N0", "N1", weight: 0.612)
pr.add("N2", "N1", weight: 0.492)
pr.add("N2", "N0", weight: 0.67)
p pr.calculate
