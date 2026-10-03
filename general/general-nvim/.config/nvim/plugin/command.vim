" Capture output from a command to register @m, to paste, press "mp
command! -nargs=1 -complete=command Redir call utils#CaptureCommandOutput(<q-args>)

command! -bar -bang -nargs=+ -complete=file Edit call utils#MultiEdit([<f-args>])
call utils#Cabbrev('edit', 'Edit')

call utils#Cabbrev('man', 'Man')

" show current date and time in human readable format
command! -nargs=? Datetime echo utils#iso_time(<q-args>)

" Convert Markdown file to PDF
command! ToPDF call s:md_to_pdf()

function! s:md_to_pdf() abort
  " check if pandoc is installed
  if executable('pandoc') != 1
    echoerr "pandoc not found"
    return
  endif

  let l:md_path = expand("%:p")
  if l:md_path ==# ''
    echohl WarningMsg | echomsg 'ToPDF: save the buffer to a file first' | echohl None
    return
  endif
  let l:pdf_path = fnamemodify(l:md_path, ":r") .. ".pdf"

  let l:header_path = stdpath('config') . '/resources/head.tex'

  " argv list: no shell, so spaces, $ and ; in paths are safe
  let l:cmd = ['pandoc', '--pdf-engine=xelatex', '--highlight-style=zenburn', '--table-of-content',
        \ '--include-in-header=' . l:header_path, '-V', 'fontsize=10pt', '-V', 'colorlinks',
        \ '-V', 'toccolor=NavyBlue', '-V', 'linkcolor=red', '-V', 'urlcolor=teal',
        \ '-V', 'filecolor=magenta', '-s', l:md_path, '-o', l:pdf_path]

  let l:id = jobstart(l:cmd, {'on_exit': function('s:md_to_pdf_done', [l:pdf_path])})

  if l:id == 0 || l:id == -1
    echoerr "Error running command"
  endif
endfunction

" open the PDF after a successful run (mac / windows only, as before)
function! s:md_to_pdf_done(pdf_path, job_id, code, event) abort
  if a:code != 0
    echohl WarningMsg | echomsg 'ToPDF: pandoc failed (exit ' . a:code . ')' | echohl None
    return
  endif
  if g:is_mac
    call jobstart(['open', a:pdf_path])
  elseif g:is_win
    call jobstart(['cmd', '/c', 'start', '', a:pdf_path])
  endif
endfunction
