" Vim filetype plugin
" This is an adaptation of the original cucumber plugin by Tim Pope
" Language:	  Behat (Gherkin)
" Maintainer: Vincent Velociter
" Url:        https://github.com/veloce/vim-behat

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

let s:behat_executables = ['php app/console -e=test behat', 'php behat.phar', './behat', 'bin/behat', 'behat']
if exists("g:behat_executables")
  let s:behat_executables = g:behat_executables + s:behat_executables
endif

if !exists("g:no_plugin_maps") && !exists("g:no_behat_maps")
  nnoremap <silent><buffer> <C-]>       :<C-U>exe <SID>jump('tjump')<CR>
  nnoremap <silent><buffer> <C-W>]      :<C-U>exe <SID>jump('stjump')<CR>
  nnoremap <silent><buffer> <C-W><C-]>  :<C-U>exe <SID>jump('stjump')<CR>
  nnoremap <silent><buffer> <C-W>}      :<C-U>exe <SID>jump('ptjump')<CR>
  let b:undo_ftplugin .= "| sil! nunmap <buffer> <C-]>| sil! nunmap <buffer> <C-W>]| sil! nunmap <buffer> <C-W><C-]>| sil! nunmap <buffer> <C-W>}"
endif

function! s:jump(command)
  try
    let steps = s:steps('.')
  catch /^behat:/
    return 'echoerr v:errmsg'
  endtry
  if len(steps) == 0
    return 'echoerr "No matching step found"'
  elseif len(steps) > 1
    return 'echoerr "Multiple matching step found"'
  else
    return a:command.' '.steps[0][1]
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
  if a:receiver =~ '^/.*/$'
    let pattern = a:receiver[1:-2]
  else
    return 0
  endif
  try
    let pattern = substitute(pattern, '\\\@<!(?P<[^>]\+>\([^)]\+)\?[*+]\?\))','\1','g')
    let vimpattern = substitute(substitute(pattern,'\\\@<!(?:','%(','g'),'\\\@<!\*?','{-}','g')
    if a:target =~# '\v'.vimpattern
      return 1
    endif
  catch
  endtry
endfunction

function! s:definfo()
  let steps = []
  for cmd in s:behat_executables
    if exists('b:behat_cmd_args')
      let cmd = cmd . ' ' . b:behat_cmd_args
    endif
    let output = system(cmd.' '.b:behat_root.' -di')
    if v:shell_error == 0
      let definfos = filter(split(output, "\n"), 'v:val !~ "\\%(^$\\|\\s\\+-\\)"')
      let index = 0
      while index < len(definfos)
        let pattern = matchstr(definfos[index],'^\s\?\w\+\s\zs.*$')
        if pattern !~ '^\/\^'
          let pattern = '/^' . pattern . '$/'
        endif
        let source = matchstr(definfos[index + 1],'#\s\zs.*$')
        let class = matchstr(source, '\w\+\ze::')
        let method = matchstr(source, '::\zs\w\+\ze()')
        let steps += [[class,method,pattern]]
        let index = index + 2
      endwhile
      return steps
    endif
  endfor
  let v:errmsg = 'behat: behat command not found or returned an error'
  throw v:errmsg
endfunction

function! s:deflist()
  let steps = []
  for cmd in s:behat_executables
    if exists('b:behat_cmd_args')
      let cmd = cmd . ' ' . b:behat_cmd_args
    endif
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
  try
    let definitions = s:deflist()
  catch /^behat:/
    return -1
  endtry
  let steps = []
  for step in definitions
    if step[0] ==# type
      if step[1] =~ '^\/\^.*\$\/$'
        let pattern = step[1][2:-3]
        let pattern = substitute(pattern,'\C^(?:|\?\(\w\{-1,}\) )?\?','\1 ','')
        let pattern = s:bsub(pattern,'\\d','1')
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
  return sort(filter(steps,'strpart(v:val,0,strlen(a:base)) ==# a:base'))
endfunction

" vim:set sts=2 sw=2:
