" Vim filetype plugin
" This is an adaption of the original cucumber.vim plugin by Tim Pope
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

if !exists("g:no_plugin_maps") && !exists("g:no_behat_maps")
  nnoremap <silent><buffer> <C-]>       :<C-U>exe <SID>jump('tjump',v:count)<CR>
  nnoremap <silent><buffer> <C-W>]      :<C-U>exe <SID>jump('stjump',v:count)<CR>
  nnoremap <silent><buffer> <C-W><C-]>  :<C-U>exe <SID>jump('stjump',v:count)<CR>
  nnoremap <silent><buffer> <C-W>}      :<C-U>exe <SID>jump('ptjump',v:count)<CR>
  let b:undo_ftplugin .= "| sil! nunmap <buffer> <C-]>| sil! nunmap <buffer> <C-W>]| sil! nunmap <buffer> <C-W><C-]>| sil! nunmap <buffer> <C-W>}"
endif

function! s:jump(command,count)
  let steps = s:steps('.')
  if len(steps) == 0 || len(steps) < a:count
    return 'echoerr "No matching step found"'
  elseif len(steps) > 1 && !a:count
    return 'echoerr "Multiple matching steps found"'
  else
    let c = a:count ? a:count-1 : 0
    return a:command.' '.step[c][1]
  endif
endfunction

function! s:steps(lnum)
  let c = indent(a:lnum) + 1
  while synIDattr(synID(a:lnum,c,1),'name') !~# '^$\|Region$'
    let c = c + 1
  endwhile
  let step = matchstr(getline(a:lnum)[c-1 : -1],'^\s*\zs.\{-\}\ze\s*$')
  return filter(s:definfo(),'s:stepmatch(v:val[2],step)')
endfunction

function! s:stepmatch(receiver,target)
endfunction

function! s:deflist()
  let steps = []
  for cmd in s:behat_cmds
    " behat >=2.2
    let output = system(cmd.' '.b:behat_root.' -dl')
    if v:shell_error == 0
      for def in split(output, "\n")
        let def = substitute(def,'^\s\+','','')
        let type = matchstr(def,'\w\+')
        let pattern = matchstr(def,'\w\+\s\zs.*$')
        if pattern !~ '^\/\^'
          let pattern = '/^' . pattern . '$/'
        endif
        let steps += [[type,pattern]]
      endfor
      return steps
    endif
    " behat <2.2
    let output = system(cmd.' '.b:behat_root.' --definitions')
    if v:shell_error == 0
      for def in split(output, "\n")
        let def = substitute(def,'^\s\+','','')
        let type = matchstr(def,'\w\+')
        let pattern = matchstr(def,'\/\^.\{-}\$\/')
        let steps += [[type,pattern]]
      endfor
      return steps
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
    let definitions = s:deflist()
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
        let pattern = s:bsub(pattern,'[[:alnum:]. _-][?*]?\=','')
        let pattern = s:bsub(pattern,'\[\([^^]\).\{-\}\]','\1')
        let pattern = s:bsub(pattern,'\(\w\+\)\%(|\w\+\)\+','\1')
        let pattern = s:bsub(pattern,'(?P<\([^>]\+\)>\%(([^)]\+)\)\?.\{-})','{\1}')
        let pattern = s:bsub(pattern,'+?\=','')
        let pattern = s:bsub(pattern,'?:','')
        let pattern = s:bsub(pattern,'(\([[:alnum:]. _-]\{-\}\))','\1')
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
