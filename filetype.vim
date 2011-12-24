" Vim support file to detect file types
" This is necessary to ensure that no other autocommand will set cucumber
" filetype after this one if g:feature_filetype is set to behat
"
" Maintainer:	Vincent Velociter

if exists("did_load_filetypes")
  finish
endif

au BufRead,BufNewFile *.feature call s:FTfeature()

func! s:FTfeature()
  if exists("g:feature_filetype")
    exe "setf " . g:feature_filetype
  else
    setf cucumber
  endif
endfunc
