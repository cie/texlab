# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "texlab"
  gem.homepage = "http://github.com/cie/texlab"
  gem.license = "MIT"
  gem.summary = %Q{a tool to create documents with latex and ruby}
  gem.description = %Q{texlab a toolkit based on erb that for creating documents and doing calculations at the same time. It is capable to output the proper number of significant digits, generate tables and plots using gnuplot. It has a simple DSL.}
  gem.email = "kallo.bernat@gmail.com"
  gem.authors = ["Bernát Kalló"]
  gem.executables = ["texlab-compile"]
  gem.files = FileList["lib/**/*.rb", "bin/*", "[A-Z]*", "spec/**/*"].to_a
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "texlab #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
