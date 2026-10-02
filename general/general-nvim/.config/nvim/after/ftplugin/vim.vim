" Disable inserting comment leader after hitting o or O or <Enter>
setlocal formatoptions-=o
setlocal formatoptions-=r

" Set the folding related options for vim script. Setting folding option in
" modeline is annoying in that the modeline get executed each time the window
" focus is lost (see
" https://github.com/tmux-plugins/vim-tmux-focus-events/issues/14)
setlocal foldmethod=expr foldexpr=utils#VimFolds(v:lnum) foldtext=utils#MyFoldText()

" Use :help command for keyword when pressing `K` in vim file,
" see `:h K` and https://stackoverflow.com/q/15867323/6064933
setlocal keywordprg=:help

" set from Lua so the map has a desc
lua vim.keymap.set("n", "<F9>", ":source %<CR>", { buffer = true, silent = true, desc = "vim: source current file" })
