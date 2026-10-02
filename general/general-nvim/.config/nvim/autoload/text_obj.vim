function! text_obj#URL() abort
  if match(&runtimepath, 'vim-highlighturl') != -1
    " Note that we use https://github.com/itchyny/vim-highlighturl to get the URL pattern.
    let url_pattern = highlighturl#default_pattern()
  else
    let cfile = expand('<cfile>')
    " Since expand('<cfile>') also works for normal words, we need to check if
    " this is really URL using heuristics, e.g., URL length.
    if len(cfile) <= 10
      return
    endif
    " Use it as a literal string, not a regex ('\V' = very nomagic), so that
    " characters like [ ] . * in the URL do not act as regex syntax.
    let url_pattern = '\V' . escape(cfile, '\')
  endif

  " We need to find all possible URL on this line and their start, end index.
  " Then find where current cursor is, and decide if cursor is on one of the
  " URLs.
  let line_text = getline('.')
  let url_infos = []

  let [_url, _idx_start, _idx_end] = matchstrpos(line_text, url_pattern)
  while _url !=# ''
    let url_infos += [[_url, _idx_start+1, _idx_end]]
    let [_url, _idx_start, _idx_end] = matchstrpos(line_text, url_pattern, _idx_end)
  endwhile

  " echo url_infos
  " If no URL is found, do nothing.
  if len(url_infos) == 0
    return
  endif

  let [start_col, end_col] = [-1, -1]
  " If URL is found, find if cursor is on it.
  let [buf_num, cur_row, cur_col] = getcurpos()[0:2]
  for url_info in url_infos
    " echo url_info
    let [_url, _idx_start, _idx_end] = url_info
    if cur_col >= _idx_start && cur_col <= _idx_end
      let start_col = _idx_start
      let end_col = _idx_end
      break
    endif
  endfor

  " Cursor is not on a URL, do nothing.
  if start_col == -1
    return
  endif

  " Now set the '< and '> mark
  call setpos("'<", [buf_num, cur_row, start_col, 0])
  call setpos("'>", [buf_num, cur_row, end_col, 0])
  normal! gv
endfunction

function! text_obj#MdCodeBlock(type) abort
  " the parameter type specify whether it is inner text objects or around
  " text objects.

  " Decide whether the cursor is inside a fenced block by counting the fence
  " lines up to and including the cursor line: an odd count means an opening
  " fence was seen and not yet closed (cursor on the opening fence or inside),
  " an even count means outside, unless the cursor is on the closing fence.
  let fences = []
  for lnum in range(1, line('$'))
    if getline(lnum) =~# '^\s*```'
      call add(fences, lnum)
    endif
  endfor

  let cur_row = line('.')
  let k = len(filter(copy(fences), 'v:val <= cur_row'))
  if k % 2 == 1
    " inside a block (or on its opening fence); the closing fence must exist
    if k >= len(fences)
      return
    endif
    let start_row = fences[k - 1]
    let end_row = fences[k]
  elseif k > 0 && fences[k - 1] == cur_row
    " on a closing fence
    let start_row = fences[k - 2]
    let end_row = fences[k - 1]
  else
    " not inside any code block (including no fences at all)
    return
  endif

  let buf_num = bufnr()
  if a:type ==# 'i'
    let start_row += 1
    let end_row -= 1
  endif
  " empty block: nothing to select for the inner object
  if start_row > end_row
    return
  endif

  call setpos("'<", [buf_num, start_row, 1, 0])
  call setpos("'>", [buf_num, end_row, 1, 0])
  execute 'normal! `<V`>'
endfunction

function! text_obj#Buffer() abort
  let buf_num = bufnr()

  call setpos("'<", [buf_num, 1, 1, 0])
  call setpos("'>", [buf_num, line('$'), 1, 0])
  execute 'normal! `<V`>'
endfunction
