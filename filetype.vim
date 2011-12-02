" Vim support file to detect file types
" This is necessary to be sure that no other autocommand will set cucumber
" filetype after this one if g:filetype_feature is set to behat
"
" Maintainer:	Vincent Velociter
" Last Change:	2011 dec 02

if exists("did_load_filetypes")
  finish
endif

au BufRead,BufNewFile *.feature call s:FTfeature()

func! s:FTfeature()
  if exists("g:filetype_feature")
    exe "setf " . g:filetype_feature
  else
    setf cucumber
  endif
endfunc
