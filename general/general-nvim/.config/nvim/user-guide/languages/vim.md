<!-- chapter: Vimscript -->
[Back to the guide index](../README.md)

# 85. Vimscript (snippets, source and settings)

This chapter covers the custom Vimscript snippets (file `my_snippets/vim.snippets`) and the few things the config does for `.vim` files. Only what is stated here has been checked in the config; no Vimscript language server is described in this guide.

## What you get

| Feature | What it does | Needs |
| --- | --- | --- |
| **Source the file** (`<Space>rf` or `<F9>`) | Runs `:source %` on the current file (section 19) | Nothing |
| **`K`** | Opens `:help` for the word under the cursor (`keywordprg=:help`) | Nothing |
| **Folding** | Folds use `utils#VimFolds` for the fold level and `utils#MyFoldText` for the fold line (section 18) | The `utils` autoload functions of the config |
| **Comment leader** | Pressing `o`, `O` or `<Enter>` after a comment line does not continue the comment | Nothing |
| **Line-length marker** | The coloured column marker sits at column 80 for Vim script (section 41) | Nothing |
| **Tree-sitter** | The `vim` parser gives syntax highlighting (bundled with Neovim) | Nothing |
| **Snippets** | See Snippets below | Nothing |

These settings live in `after/ftplugin/vim.vim`.

## Snippets

Source: `my_snippets/vim.snippets` (2 snippets). Type the trigger in insert mode in a Vim script buffer and expand it with `<Ctrl-j>` (section 15); the text in quotes after each trigger below is its description as the completion menu shows it; `<Ctrl-j>` / `<Ctrl-k>` jump to the next / previous placeholder. Placeholders are shown below in tab-stop order. After the last placeholder the cursor leaves the block (`$0`).

**`fun`**: "Vimscript function declared with abort (args are comma separated)". A function. The `!` replaces an older function of the same name when you source the file again, and `abort` stops the function at the first error. The name `MyFunc` is preselected. A name for a script-local function starts with `s:`; a function in an autoload file looks like `folder#Name`.

```vim
function! MyFunc(args) abort
	body
endfunction
```

Example: `MyFunc` replaced by `s:Greet`, `args` by `who`, body `echo "hello " . a:who`.

**`aug`**: "Autocommand group that clears itself first (EVENT: BufWritePost, FileType, ...; PATTERN: *.vim, ...; start of line)". An autocommand group. The `autocmd!` line empties the group first, so sourcing the file twice does not register the autocommand twice.

```vim
augroup GROUP_NAME
	autocmd!
	autocmd EVENT PATTERN command
augroup END
```

Example: `GROUP_NAME` replaced by `MyGroup`, `EVENT` by `BufWritePre`, `PATTERN` by `*.txt`, `command` by `%s/\s\+$//e`.

## Related sections

Section 15 and 52 (snippets), 18 (folding), 19 (code running), 41 (filetype settings), 78 (Java chapter, section 9 has the same snippet layout).
