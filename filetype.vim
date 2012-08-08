" Vim support file to detect file types
" This is necessary to ensure that no other autocommand will set cucumber
" filetype after this one if g:feature_filetype is set to behat
"
" Maintainer:	Vincent Velociter

if exists("did_load_filetypes")
  finish
endif

autocmd BufRead,BufNewFile *.feature call s:FTfeature()

function! s:FTfeature()
  if exists("g:feature_filetype")
    execute "setfiletype " . g:feature_filetype
  else
    setfiletype cucumber
  endif
endfunction
