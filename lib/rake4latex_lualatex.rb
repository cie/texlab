=begin rdoc
Special variant for rake4latex with lualatex.
=end

#
#Load the base functions and load subfiles.
#
require 'rake4latex/base'

#
#Define the pdf-creation via lualatex
#

desc "Build a pdf-file with luaLaTeX"
rule '.pdf' => '.tex' do |t|
  runner =   Rake4LaTeX::LaTeXRunner.new( 
    :main_file => t.source,
    :program => :lualatex,
    :dummy => nil
    )
  runner.execute  #Does all the work and calls the "post-prerequisites"
end
