# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'text_rank/version'

Gem::Specification.new do |spec|
  spec.name          = 'text_rank'
  spec.version       = TextRank::VERSION
  spec.authors       = ['David McCullars']
  spec.email         = ['david.mccullars@gmail.com']

  spec.summary       = %q{Implementation of TextRank solution to ranked keyword extraction}
  spec.description   = %q{See https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&ved=0ahUKEwjK9tfHxcvMAhVOzGMKHdaQBeEQFggdMAA&url=https%3A%2F%2Fweb.eecs.umich.edu%2F~mihalcea%2Fpapers%2Fmihalcea.emnlp04.pdf&usg=AFQjCNHL5SGlxLy4qmEg1yexaKGZK_Q7IA}
  spec.homepage      = 'https://github.com/david-mccullars/text_rank'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler',    '~> 1.11'
  spec.add_development_dependency 'rake',       '~> 10.0'
  spec.add_development_dependency 'rspec',      '~> 3.0'
  spec.add_development_dependency 'simplecov',  '~> 0.11'
  spec.add_development_dependency 'codeclimate-test-reporter'

  spec.add_development_dependency 'engtagger',  '~> 0.2.0' # Optional runtime dependency but needed for specs
  spec.add_development_dependency 'nokogiri',   '~> 1.0'   # Optional runtime dependency but needed for specs
end
