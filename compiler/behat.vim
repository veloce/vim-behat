" Vim compiler file
" Compiler:	Behat
" Maintainer:	Vincent Velociter

if exists("current_compiler")
  finish
endif
let current_compiler = "behat"

if exists(":CompilerSet") != 2		" older Vim always used :setlocal
  command -nargs=* CompilerSet setlocal <args>
endif

let s:cpo_save = &cpo
set cpo-=C

if exists("g:behat_cmds")
  let s:behat_cmds = g:behat_cmds
else
  let s:behat_cmds = ['php app/console -e=test behat', 'php behat.phar', './behat', 'behat']
endif

function! s:findBehatCmd()
  for cmd in s:behat_cmds
    call system(cmd.' -h')
    if v:shell_error == 0
      return cmd
    endif
  endfor
  return 'echoerr "behat: behat command not found"'
endfunction

let s:behat_cmd = substitute(call('s:findBehatCmd', []), '\s', '\\ ', 'g')

exe 'CompilerSet makeprg='.s:behat_cmd.'\ -f\ progress\ $*'

CompilerSet errorformat=%Z\ \ \ \ From\ scenario%.%##\ %f:%l,%E%m(),%-G%.%#

let &cpo = s:cpo_save
unlet s:cpo_save

" vim:set sw=2 sts=2:
