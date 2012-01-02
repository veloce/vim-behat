# behat.vim

This is an adaptation of the [cucumber.vim](https://github.com/tpope/vim-pathogen)
for [Behat](http://behat.org).

Behat uses the same langage as cucumber (Gherkin), so indent and syntax scripts
are the same as cucumber's runtime files.  Only the compiler and ftplugin change.

Features:

* autocompletion of steps (with `<C-X><C-O>`)
* jump to step definition (**behat version from 2.2 and ctags are required**) with
tag commands `<C-]>`, `<C-W>]`, `<C-W>}`
* compiler plugin allow you to run behat with `:make` and see errors in the quickfix
window

## Installation

You can download the archive, but I recommand using [pathogen.vim](https://github.com/tpope/vim-pathogen):

    cd ~/.vim/bundle
    git clone git://github.com/veloce/vim-behat.git

Behat feature files share the same `.feature` extension with cucumber, so in
order to choose the behat filetype plugin, you need to set the following global 
in your .vimrc:

    let feature_filetype='behat'

If you don't, cucumber will be used instead.
