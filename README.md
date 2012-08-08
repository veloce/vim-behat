# behat.vim

This is an adaptation of [cucumber.vim](https://github.com/tpope/vim-cucumber)
for [Behat](http://behat.org).

Behat uses the same langage as cucumber (Gherkin), so indent and syntax scripts
are the same as cucumber runtime files.  Only the compiler and ftplugin change.

Features:

* autocompletion of steps (with `<C-X><C-O>`)
* jump to step definition (**behat version from 2.2 and ctags are required**) with
tag commands `<C-]>`, `<C-W>]`, `<C-W>}`
* compiler plugin that allow you to run behat with `:make` and see errors in the quickfix
window
* Copy the behat command to run features in the current buffer into the clipboard (`:BehatCmdToClipBoard`)

## Installation

You can download the archive, and uncompress it in your `~/.vim` folder. 
I recommand using [pathogen.vim](https://github.com/tpope/vim-pathogen), though:

    cd ~/.vim/bundle
    git clone git://github.com/veloce/vim-behat.git

Behat feature files share the same `.feature` extension with cucumber, so in
order to choose the behat filetype plugin, you need to set the following global 
in your `.vimrc`:

    let feature_filetype='behat'

If you don't, cucumber will be used as filetype by default.

## Configuration

You can define two variables to change the default behaviour.

The plugin tries successively several behat executables to find the good one
(`php behat.phar`, `bin/behat`, etc). You can define a custom list that will
be prepended to the default path with `g:behat_executables`.

Example:

    let g:behat_executables = ['behat.sh']

You can also define a `b:behat_cmd_args` in a `~/.vim/ftplugin/behat.vim` file
to add arguments to the behat command. This is useful if you use profiles,
or/and a different config file.

Example:

    let b:behat_cmd_args = '-c path/to/behat.yml'

This variable is bound to the current buffer, so it let you add custom logic 
to define it.

For instance, you can set a profile according to features location:

    if match(expand('%:h'), 'features\/foo') != -1
        let b:behat_cmd_args = '-p foo'
    elseif match(expand('%:h'), 'features\/bar') != -1
        let b:behat_cmd_args = '-p bar'
    endif

