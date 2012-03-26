=begin rdoc
Special variant for rake4latex with xelatex.
=end

#
#Load the base functions and load subfiles.
#
require 'rake4latex/base'

#
#Define the pdf-creation via xelatex
#

desc "Build a pdf-file with xeLaTeX"
rule '.pdf' => '.tex' do |t|
  runner =   Rake4LaTeX::LaTeXRunner.new( 
    :main_file => t.source,
    :program => :xelatex,
    :dummy => nil
    )
  runner.execute  #Does all the work and calls the "post-prerequisites"
end
