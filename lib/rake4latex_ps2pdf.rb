=begin rdoc
Special variant for rake4latex with ps2pdf
=end

#
#Load the base functions and load subfiles.
#
require 'rake4latex/base'

#
#Define the pdf-creation via dvips ps2dvi
#
desc "Build a pdf-file via ps2dvi"
rule '.pdf' => '.ps' do |t|
  Rake4LaTeX::Logger.info("Call ps2pdf for <#{t.source}>")
  cmd = Rake4LaTeX.build_cmd( 'ps2pdf', :filename => t.source )
  
  stdout, stderr = catch_screen_output{ 
    sh cmd
    #stdout -> empty
    #stderr -> "ps2pdf testdocument.ps"
  }
  if $? != 0
    Rake4LaTeX::Logger.fatal("There where ps2pdf errors. \n#{stdout}")
  end
end

