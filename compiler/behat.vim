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

CompilerSet makeprg=behat

CompilerSet errorformat=
      \%W%m\ (Behat::Undefined),
      \%E%m\ (%.%#),
      \%Z%f:%l,
      \%Z%f:%l:%.%#

let &cpo = s:cpo_save
unlet s:cpo_save

" vim:set sw=2 sts=2:
