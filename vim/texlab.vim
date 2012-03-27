let $TEXLAB = expand('<sfile>:p:h:h')

"" The followning lines are copied from evim.vim

" Don't use Vi-compatible mode.
set nocompatible

" Use the mswin.vim script for most mappings
source $VIMRUNTIME/mswin.vim

" Vim is in Insert mode by default
set insertmode

" Make a buffer hidden when editing another one
"set hidden

" Make cursor keys ignore wrapping
inoremap <Down> <C-R>=pumvisible() ? "\<lt>Down>" : "\<lt>C-O>gj"<CR>
inoremap <Up> <C-R>=pumvisible() ? "\<lt>Up>" : "\<lt>C-O>gk"<CR>

" CTRL-F does Find dialog instead of page forward
noremap <C-F> :promptfind<CR>
vnoremap <C-F> y:promptfind <C-R>"<CR>
onoremap <C-F> <C-C>:promptfind<CR>
inoremap <C-F> <C-O>:promptfind<CR>
cnoremap <C-F> <C-C>:promptfind<CR>
inoremap <ESC> <C-O>:nohlsearch<CR><C-\><C-G>


set backspace=2		" allow backspacing over everything in insert mode
set autoindent		" always set autoindenting on
"if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
  "else
  "set backup		" keep a backup file
  "endif
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set incsearch		" do incremental searching
set mouse=a		" always use the mouse

" Don't use Ex mode, use Q for formatting
map Q gq

" Switch syntax highlighting on, when the terminal has colors
" Highlight the last used search pattern on the next search command.
syntax on
set hlsearch
nohlsearch

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " For all text files set 'textwidth' to 78 characters.
  au FileType text setlocal tw=78

endif " has("autocmd")

" end of evim.vim

set autoindent softtabstop=2 shiftwidth=2 smarttab expandtab smartindent
set ignorecase showmatch smartcase incsearch hlsearch
set showcmd nohidden
set autowrite
set background=light
set modeline secure
set fencs=utf-8,latin2
set spelllang=hu spell
set linebreak

" set up ruby
rubyfile $TEXLAB/lib/texlab.rb

exec 'inoremap <F9> <C-O>:!rake -f ' . shellescape(expand('$TEXLAB/lib/texlab.rake')) . ' %:s?\.[^.]\+$?.pdf?<CR>' 
exec 'noremap <F9> :!rake -f ' . shellescape(expand('$TEXLAB/lib/texlab.rake')) . ' %:s?\.[^.]\+$?.pdf?<CR>' 
"inoremap <F9> <C-O>:ruby Rake::Task["compile"].invoke<CR>

exec 'inoremap <F8> <C-O>:!ruby ' . shellescape(expand('$TEXLAB/bin/texlab-console')) . ' %<CR>'
exec 'noremap <F8> :!ruby ' . shellescape(expand('$TEXLAB/bin/texlab-console')) . ' %<CR>'

inoremap <C-O> <C-O>:browse confirm e<CR>
inoremap <M-Left> <C-O><C-O>
inoremap <M-Left> <C-O><C-I>
noremap <C-S>          :if expand("%") == ""<Bar>browse confirm w<Bar>else<Bar>confirm w<Bar>endif<CR>
vnoremap <C-S>         <C-C>:if expand("%") == ""<Bar>browse confirm w<Bar>else<Bar>confirm w<Bar>endif<CR><C-\><C-G>
inoremap <C-S>         <C-O>:if expand("%") == ""<Bar>browse confirm w<Bar>else<Bar>confirm w<Bar>endif<CR><C-\><C-G>

inoremap <ESC>: <C-O>:


" set file type for texlab files
au BufNewFile,BufRead *.texlab			let b:eruby_subtype = "tex" | set ft=eruby
" set file type for new files
au BufNewFile *                  		let b:eruby_subtype = "tex" | set ft=eruby

let b:eruby_subtype = "tex" | set ft=eruby


" Delete menu items
aunmenu ToolBar.SaveAll
aunmenu ToolBar.Print
aunmenu ToolBar.RunScript
aunmenu ToolBar.LoadSesn
aunmenu ToolBar.SaveSesn
aunmenu ToolBar.Help
aunmenu ToolBar.FindHelp
aunmenu ToolBar.RunCtags
aunmenu ToolBar.TagJump
aunmenu ToolBar.-sep5-
aunmenu ToolBar.-sep7-

set guioptions+=aeimgTrb
set guioptions-=t

" folding
set foldcolumn=1 foldmethod=syntax foldlevel=10000

" load plugins
"source <sfile>:p:h/plugin/**/*.vim

" cd next to file
if expand("%") != ""
  cd %:p:h
endi
au Bufnew * lcd <afile>:p:h

" load texlabrc
if filereadable(expand("~/.texlabrc"))
  source ~/.texlabrc
endif
