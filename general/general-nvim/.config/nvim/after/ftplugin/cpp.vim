" Disable inserting comment leader after hitting o or O or <Enter>
setlocal formatoptions-=o
setlocal formatoptions-=r

" <F9> compile & run: only when a C++ compiler is on PATH (e.g. g++ from the c-cpp devShell)
if executable('clang++') || executable('g++')
  nnoremap <silent> <buffer> <F9> :call <SID>compile_run_cpp()<CR>
endif

function! s:compile_run_cpp() abort
  let src_path = expand('%:p')
  let src_noext = expand('%:p:r')
  if src_path ==# ''
    echohl WarningMsg | echomsg 'Save the buffer to a file first' | echohl None
    return
  endif

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
  " Paths are argv entries of sh (never spliced into a command string), so spaces, $, ; and
  " quotes in file names are safe. $0 is the output binary, "$@" the compile command.
  call jobstart(['sh', '-c', '"$@" && "$0"', src_noext, prog, '-Wall', '-Wextra', '-std=c++20', '-O2', src_path, '-o', src_noext], {'term': v:true})
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
