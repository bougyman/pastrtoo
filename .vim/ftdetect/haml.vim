" Vim file to detect ruby/rails file types
"
" Maintainer:	Tj Vanderpoel <bougy.man@gmail.com>
" Last Change:	2008 Oct 10

" only load once
if exists("b:did_load_haml_filetypes")
  finish
endif
let b:did_load_haml_filetypes = 1

augroup filetypedetect

" Haml
au BufNewFile,BufRead *.haml	setf haml

augroup END
