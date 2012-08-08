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

let s:behat_executables = ['php app/console -e=test behat', 'php behat.phar', './behat', 'bin/behat', 'behat']
if exists("g:behat_executables")
  let s:behat_executables = g:behat_executables + s:behat_executables
endif

function! s:findBehatCmd()
  for cmd in s:behat_executables
    call system(cmd.' -h')
    if v:shell_error == 0
      if exists('b:behat_cmd_args')
        let cmd = cmd . ' ' . b:behat_cmd_args
      endif
      return cmd
    endif
  endfor
  return 'echoerr "behat: behat command not found or returned an error"'
endfunction

command! -buffer BehatCmdToClipBoard execute "let @*=call('s:findBehatCmd',[]).' '.expand('%')"

let s:behat_cmd = substitute(call('s:findBehatCmd', []), '\s', '\\ ', 'g')

execute 'CompilerSet makeprg='.s:behat_cmd.'\ -f\ progress\ $*'

CompilerSet errorformat=%Z\ \ \ \ From\ scenario%.%##\ %f:%l,%E%m(),%-G%.%#

let &cpo = s:cpo_save
unlet s:cpo_save

" vim:set sw=2 sts=2:
