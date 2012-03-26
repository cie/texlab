=begin rdoc
Special variant for rake4latex with pdflatex.
=end

#
#Load the base functions and load subfiles.
#
require 'rake4latex/base'

#
#Define the pdf-creation via pdflatex
#

desc "Build a pdf-file with pdfLaTeX"
rule '.pdf' => '.tex' do |t|
  runner =   Rake4LaTeX::LaTeXRunner.new( 
    :main_file => t.source,
    :program => :pdflatex,
    :dummy => nil
    )
  runner.execute  #Does all the work and calls the "post-prerequisites"
end
