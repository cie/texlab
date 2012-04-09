require "rake4latex"

desc "Compile a texlab file to tex"
rule ".tex" => ".texlab" do |t|
  sh %("texlab-compile" "#{t.source}")
end

