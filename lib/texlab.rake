require "rubygems"
require "rake4latex"

rule ".tex" => ".texlab" do |t|
  sh %("#{File.expand_path(__FILE__+"/../../bin/texlab-compile")}" "#{t.source}" > "#{t.name}")
end

