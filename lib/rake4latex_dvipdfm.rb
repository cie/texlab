=begin rdoc
Special variant for rake4latex with ps2pdf
=end

#
#Load the base functions and load subfiles.
#
require 'rake4latex/base'

#
#Define the pdf-creation via pdflatex
#

#~ desc "Build a pdf-file with pdfLaTeX"
#~ rule '.pdf' => '.tex' do |t|
  #~ runner =   LaTeXRunner.new( 
    #~ :main_file => t.source,
    #~ :program => :pdflatex,
    #~ :dummy => nil
    #~ )
  #~ runner.execute  #Does all the work and calls the "post-prerequisites"
#~ end

desc "Build a pdf-file via dvipdfm."
rule '.pdf' => '.dvi' do |t|
  Rake4LaTeX::Basefile.set(t.source).logger.info("Call dvipdfm for <#{t.source}>")
  cmd = Rake4LaTeX.build_cmd( 'dvipdfm', :filename => t.source )
  
  stdout, stderr = catch_screen_output{ 
    sh cmd
    #stdout -> empty
    #stderr -> "ps2pdf testdocument.ps"
    puts stdout
    puts '==========='
    puts stderr
  }
  if $? != 0
    Rake4LaTeX::Basefile.set(t.source).logger.fatal("There where dvipdfm errors. \n#{stdout}")
  end
end
