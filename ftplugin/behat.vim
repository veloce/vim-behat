" Vim filetype plugin
" Language:	Behat
" Maintainer:	Vincent Velociter
" Last Change:	2011 12 02

" Only do this when not done yet for this buffer
if (exists("b:did_ftplugin"))
  finish
endif
let b:did_ftplugin = 1

setlocal formatoptions-=t formatoptions+=croql
setlocal comments=:# commentstring=#\ %s
" setlocal omnifunc=BehatComplete

