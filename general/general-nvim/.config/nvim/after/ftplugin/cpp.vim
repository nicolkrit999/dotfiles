" Disable inserting comment leader after hitting o or O or <Enter>
setlocal formatoptions-=o
setlocal formatoptions-=r

" <F9> compile & run: only when a C++ compiler is on PATH (e.g. g++ from the c-cpp devShell)
if executable('clang++') || executable('g++')
  nnoremap <silent> <buffer> <F9> :call <SID>compile_run_cpp()<CR>
endif

function! s:compile_run_cpp() abort
  let src_path = expand('%:p:~')
  let src_noext = expand('%:p:~:r')
  " The building flags
  let _flag = '-Wall -Wextra -std=c++20 -O2'

  if executable('clang++')
    let prog = 'clang++'
  elseif executable('g++')
    let prog = 'g++'
  else
    echohl WarningMsg
    echomsg 'No C++ compiler (clang++/g++) on PATH: open nvim inside the c-cpp devShell'
    echohl None
    return
  endif
  call s:create_term_buf('h', 20)
  execute printf('term %s %s %s -o %s && %s', prog, _flag, src_path, src_noext, src_noext)
  startinsert
endfunction

function s:create_term_buf(_type, size) abort
  set splitbelow
  set splitright
  if a:_type ==# 'v'
    vnew
  else
    new
  endif
  execute 'resize ' . a:size
endfunction
