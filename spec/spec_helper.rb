$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

require 'text_rank'
# Ensure all files get loaded (for coverage sake)
Dir[File.expand_path('../../lib/text_rank/**/*.rb', __FILE__)].sort.each do |f|
  require f[%r{lib/(.*)\.rb$}, 1]
end
