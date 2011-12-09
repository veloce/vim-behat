" Vim filetype plugin
" This is an adaption of the original cucumber.vim plugin by Tim Pope for
" behat
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
setlocal omnifunc=BehatComplete

let b:undo_ftplugin = "setl fo< com< cms< ofu<"

let b:behat_root = expand('%:p:h:s?.*[\/]\%(features\|stories\)\zs[\/].*??\c')

let s:behat_cmds = ['php app/console -e=test behat', './behat', 'php behat.phar', 'bin/behat', 'behat']
function! s:definitions()
  for cmd in s:behat_cmds
    let shellcmd = cmd.' '.b:behat_root.' --definitions'
    let output = system(shellcmd)
    if v:shell_error == 0
      let val = []
      for def in split(output, "\n")
        let def = substitute(def,'^\s\+','','')
        let type = matchstr(def,'\w\+')
        let pattern = matchstr(def,'\/\^.\{-}\$\/')
        let val += [[type, pattern]]
      endfor
      return val
    endif
  endfor
  let v:errmsg = 'behat: behat command not found or returned an error'
  throw v:errmsg
endfunction

function! s:bsub(target,pattern,replacement)
  return  substitute(a:target,'\C\\\@<!'.a:pattern,a:replacement,'g')
endfunction

function! BehatComplete(findstart,base) abort
  try
    let definitions = s:definitions()
  catch /^behat:/
    return -1
  endtry
  let indent = indent('.')
  let group = synIDattr(synID(line('.'),indent+1,1),'name')
  let type = matchstr(group,'\Ccucumber\zs\%(Given\|When\|Then\)')
  let e = matchend(getline('.'),'^\s*\S\+\s')
  if type == '' || col('.') < col('$') || e < 0
    return -1
  endif
  if a:findstart
    return e
  endif
  let steps = []
  for step in definitions
    if step[0] ==# type
      if step[1] =~ '^[''"]'
        let steps += [step[1][1:-2]]
      elseif step[1] =~ '^\/\^.*\$\/$'
        let pattern = step[1][2:-3]
        let pattern = substitute(pattern,'\C^(?:|\?\(\w\{-1,}\) )?\?','\1 ','')
        let pattern = s:bsub(pattern,'\\[Sw]','w')
        let pattern = s:bsub(pattern,'\\d','1')
        let pattern = s:bsub(pattern,'\\[sWD]',' ')
        let pattern = s:bsub(pattern,'\[\^\\\="\]','_')
        let pattern = s:bsub(pattern,'[[:alnum:]. _-][?+*]?\=','')
        let pattern = s:bsub(pattern,'\[\([^^]\).\{-\}\]','\1')
        let pattern = s:bsub(pattern,'(?P<\([^>]\+\)>\%(([^)]\+)\)\?.\{-})','{\1}')
        let pattern = s:bsub(pattern,'+?\=','')
        let pattern = s:bsub(pattern,'(\([[:alnum:]. -]\{-\}\))','\1')
        let pattern = s:bsub(pattern,'\\\([[:punct:]]\)','\1')
        if pattern !~ '[\\*?]'
          let steps += [pattern]
        endif
      endif
    endif
  endfor
  call filter(steps,'strpart(v:val,0,strlen(a:base)) ==# a:base')
  return sort(steps)
endfunction

" vim:set sts=2 sw=2:
