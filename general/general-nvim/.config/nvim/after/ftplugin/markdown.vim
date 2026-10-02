setlocal concealcursor=c
setlocal synmaxcol=3000  " For long Chinese paragraphs

setlocal wrap

" Fix minor issue with footnote, see https://github.com/vim-pandoc/vim-markdownfootnotes/issues/22
" Also remove the plugin's default <Leader>f insert-mode mapping which
" hijacks Space+f when typed quickly (since leader = space).
if exists(':FootnoteNumber')
  for [s:mode, s:lhs] in [['i', '<Leader>f'], ['n', '<Leader>f'], ['i', '<Leader>r'], ['n', '<Leader>r']]
    if get(maparg(s:lhs, s:mode, 0, 1), 'buffer', 0)
      execute 'silent! ' . s:mode . 'unmap <buffer> ' . s:lhs
    endif
  endfor

  lua vim.keymap.set("n", "^^", ":<C-U>call markdownfootnotes#VimFootnotes('i')<CR>", { buffer = true, silent = true, desc = "markdown: insert footnote" })
  lua vim.keymap.set("i", "^^", "<C-O>:<C-U>call markdownfootnotes#VimFootnotes('i')<CR>", { buffer = true, silent = true, desc = "markdown: insert footnote" })
  lua vim.keymap.set("i", "@@", "<Plug>ReturnFromFootnote", { buffer = true, silent = true, remap = true, desc = "markdown: return from footnote" })
  lua vim.keymap.set("n", "@@", "<Plug>ReturnFromFootnote", { buffer = true, silent = true, remap = true, desc = "markdown: return from footnote" })
endif

" Text objects for Markdown code blocks.
" (set from Lua so the maps have a desc)
lua vim.keymap.set({ "x", "o" }, "ic", ":<C-U>call text_obj#MdCodeBlock('i')<CR>", { buffer = true, silent = true, desc = "markdown: inner code block" })
lua vim.keymap.set({ "x", "o" }, "ac", ":<C-U>call text_obj#MdCodeBlock('a')<CR>", { buffer = true, silent = true, desc = "markdown: around code block" })

" Use + to turn several lines to an unordered list.
" Ref: https://vi.stackexchange.com/q/5495/15292 and https://stackoverflow.com/q/42438795/6064933.
" expr map (not ':set ...') so a count ({N}+j) does not become a range (E481).
lua vim.keymap.set("n", "+", function() vim.o.operatorfunc = "AddListSymbol" return "g@" end, { buffer = true, expr = true, silent = true, desc = "markdown: add list symbol (+ motion)" })
lua vim.keymap.set("x", "+", ":<C-U> call AddListSymbol(visualmode(), 1)<CR>", { buffer = true, silent = true, desc = "markdown: add list symbol" })

function! AddListSymbol(type, ...) abort
  if a:0
    let line_start = line("'<")
    let line_end = line("'>")
  else
    let line_start = line("'[")
    let line_end = line("']")
  endif

  " add list symbol to each line
  for line in range(line_start, line_end)
    let text = getline(line)

    let l:end = matchend(text, '^\s*')
    if l:end == 0
      let new_text = '+ ' . text
    else
      let new_text = text[0 : l:end-1] . '+ ' . text[l:end :]
    endif

    call setline(line, new_text)
  endfor
endfunction

" Add hard line breaks for Markdown (<leader>mb + motion, or <leader>mb on a visual selection);
" set from Lua so which-key gets a desc
lua vim.keymap.set("n", "<leader>mb", function() vim.o.operatorfunc = "AddLineBreak" return "g@" end, { buffer = true, expr = true, silent = true, desc = "markdown: hard line break" })
lua vim.keymap.set("x", "<leader>mb", ":<C-U> call AddLineBreak(visualmode(), 1)<CR>", { buffer = true, silent = true, desc = "markdown: hard line break" })

function! AddLineBreak(type, ...) abort
  if a:0
    let line_start = line("'<")
    let line_end = line("'>")
  else
    let line_start = line("'[")
    let line_end = line("']")
  endif

  for line in range(line_start, line_end)
    let text = getline(line)
    " skip blank lines and lines that already end in a backslash
    if text =~# '^\s*$' || text =~# '\\$'
      continue
    endif
    " add backslash to each line
    let new_text = text . "\\"

    call setline(line, new_text)
  endfor
endfunction
