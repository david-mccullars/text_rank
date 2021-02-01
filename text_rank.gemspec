lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'text_rank/version'

Gem::Specification.new do |spec|
  spec.name          = 'text_rank'
  spec.version       = TextRank::VERSION
  spec.authors       = ['David McCullars']
  spec.email         = ['david.mccullars@gmail.com']

  spec.summary       = 'Implementation of TextRank solution to ranked keyword extraction'
  spec.description   = 'Implementation of TextRank solution to ranked keyword extraction.  See https://web.eecs.umich.edu/~mihalcea/papers/mihalcea.emnlp04.pdf'
  spec.homepage      = 'https://github.com/david-mccullars/text_rank'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.extensions    = ['ext/text_rank/extconf.rb']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rake-compiler'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov', '~> 0.17.0' # 0.18 not supported by code climate
  spec.add_development_dependency 'yard'

  spec.add_development_dependency 'engtagger' # Optional runtime dependency but needed for specs
  spec.add_development_dependency 'nokogiri'  # Optional runtime dependency but needed for specs
end
