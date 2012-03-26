=begin rdoc
Define the rules to handle dtx-files.

This rules only use pdflatex.
=end

require 'rake4latex/base'

desc "Build a pdf-file from dtx-file"
rule '.pdf' => '.dtx' do |t|
  runner =   Rake4LaTeX::LaTeXRunner.new( 
    :main_file => t.source,
    :program => :pdflatex,
    #Replace index style for makeindex and define new programm for version history.
    :programms => YAML.load(<<-settings
                                makeindex: 
                                  cmd: makeindex
                                  comment:     makeindex -s style.ist -t base.glg -o base.gls base.glo
                                  parameters: 
                                  #~ - name: -s
                                    #~ value_key: :format
                                    #~ optional: true
                                    #~ space_separated: true
                                  - value: -s gind.ist
                                  - name: -o
                                    value_key: :file_out
                                    optional: true
                                    space_separated: true
                                  - name: -t
                                    value_key: :file_log
                                    optional: true
                                    space_separated: true
                                  - value_key: :file_in
                                makeindex_glo: 
                                  cmd: makeindex
                                  comment:     makeindex -s style.ist -t base.glg -o base.gls base.glo
                                  parameters: 
                                  - value: -s gglo.ist
                                  - name: -o
                                    value_key: :file_out
                                    optional: true
                                    space_separated: true
                                  - name: -t
                                    value_key: :file_log
                                    optional: true
                                    space_separated: true
                                  - value_key: :file_in
                            settings
                          ),
    :dummy => nil
    )
  runner.execute  #Does all the work and calls the "post-prerequisites"
  #~ puts "fixme: makeindex für glo"  
  #~ `makeindex -s gglo.ist -o blindtext.gls blindtext.glo`
end

desc "Call Makeindex for version history"
tex_postrule '.gls' => '.glo' do |task|
    #makeindex writes to stderr -> catch it
    # `makeindex -s gglo.ist -o blindtext.gls blindtext.glo`
    cmd = Rake4LaTeX.build_cmd( 'makeindex_glo', { :file_in => task.source, :file_out => task.name }, task )
    task.texrunner.logger.debug("\t#{cmd}")
    stdout, stderr = catch_screen_output{ 
      sh cmd
    }
end


=begin
Conflict to DRY.
Same action is defined twice, because of two "source files".
=end
desc "Build the Style-File from ins-file"
rule '.sty' => '.ins' do |t|
  puts "Build #{t.name}"
  `latex #{t.name.ext('.ins')}`
end
desc "Build the Style-File from dtx-file"
rule '.sty' => '.dtx' do |t|
  puts "Build #{t.name}"
  `latex #{t.name.ext('.ins')}`
end

