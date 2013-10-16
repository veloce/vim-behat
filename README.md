# behat.vim

This is an adaptation of [cucumber.vim](https://github.com/tpope/vim-cucumber)
for [Behat](http://behat.org).

Behat uses the same language as cucumber to describe features, so indent and
syntax scripts are the same as cucumber runtime files. Only the compiler and
ftplugin are specific to Behat.

## Features

* **autocompletion** of steps (with `<C-X><C-O>`)
* **jump to step definition** (*behat version from 2.2 and ctags are required*) with
tag commands `<C-]>`, `<C-W>]`, `<C-W>}`
* **compiler plugin** that allows you to run behat with `:make` and see errors in
the quickfix window (enable with `:compiler behat`)
* works well with [neocomplcache](https://github.com/Shougo/neocomplcache)
(see below the settings needed)
* Copy to the **clipboard** the behat command to run features in the current buffer
(`:BehatCmdToClipBoard`). You need to enable behat compiler to have this command.

## Installation

You can download the archive, and uncompress it in your `~/.vim` folder.
I recommand using [pathogen.vim](https://github.com/tpope/vim-pathogen), though:

    cd ~/.vim/bundle
    git clone git://github.com/veloce/vim-behat.git

Behat feature files share the same `.feature` extension with cucumber, so in
order to choose the behat filetype plugin, you need to set the following global
in your `.vimrc`:

    let g:feature_filetype='behat'

If you don't, cucumber will be used as filetype by default.

## Commands

* `:BehatCmdToClipBoard`: copy the behat command for current buffer into the
  clipboard
* `:BehatInvalidatesOmniCache`: clear omni completion cache

## Configuration

### Global settings examples

```vim
" ~/.vimrc

" mandatory if you want the '*.feature' files to be set with behat filetype
let g:feature_filetype='behat'

" The plugin tries successively several behat executables to find the good one
" (php behat.phar, bin/behat, etc). You can define a custom list that will
" be prepended to the default path with g:behat_executables.
let g:behat_executables = ['behat.sh']

" if you use neocomplcache add this to enable behat completion
if !exists('g:neocomplcache_omni_patterns')
    let g:neocomplcache_omni_patterns = {}
endif
let g:neocomplcache_omni_patterns.behat = '\(When\|Then\|Given\|And\)\s.*$'

" disable omni completion steps cache
" normally you don't want to do this because it's slow (and will prevent neocomplcache from working)
" let g:behat_disable_omnicompl_cache = 1
```

### Buffer (local) settings examples

```vim
" ~/.vim/ftplugin/behat.vim

" b:behat_cmd_args let you add arguments to the behat command.
" This is useful if you use profiles, or/and a different config file.
let b:behat_cmd_args = '-c path/to/behat.yml'

" This variable is bound to the current buffer, so it let you add custom logic
" to define it.
" For instance, you can set a profile according to features location:
if match(expand('%:h'), 'features\/foo') != -1
    let b:behat_cmd_args = '-p foo'
elseif match(expand('%:h'), 'features\/bar') != -1
    let b:behat_cmd_args = '-p bar'
endif

" add this to automatically set the behat compiler (slows down buffer loading)
compiler behat
```
