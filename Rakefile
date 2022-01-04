require 'bundler/gem_tasks'
require 'rake/extensiontask'
require 'rspec/core/rake_task'
require 'yard'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

YARD::Rake::YardocTask.new

Rake::ExtensionTask.new('text_rank') do |ext|
  ext.lib_dir = 'lib/text_rank'
end
