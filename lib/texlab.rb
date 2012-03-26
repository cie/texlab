# To be sourced in VIM at startup

# Set up path
$: << (ENV["TEXLAB"]+"/lib") << (ENV["TEXLAB"]+"/lib/ruby") 
Dir.glob(ENV["TEXLAB"]+"/gems/**/lib").each do |dir|
  $: << dir
end


require "rubygems"
#require "irb"
require "yaml"
require "rake4latex"


task :compile do
  Rake::Task[VIM::Buffer.current.name.sub(/\.[^.]+\z/, ".pdf")].invoke
end


