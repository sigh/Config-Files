" Diff changes script
" Author: Dilshan Angampitiya 

" Set up default globals

" Has this plugin already been loaded?
if exists('loaded_diffchanged')
  finish
endif
let loaded_diffchanged = 1

if !exists('g:DiffChanges_patchprog')
    let g:DiffChanges_patchprog = "patch -s -R -o >(cat)"
endif

" Set up script variables
let s:diffbuf = -1
let s:bufname = "-DiffChanges-"

function! GitDiff()
    call <SID>DiffStart("git diff")
    " call <SID>DiffClose()
endfunction

" Start diffing the current file
function! <SID>DiffStart(prog)
    let l:filename = expand('%')
    let l:filetype = &filetype
    let s:diff = 1

    " create buffer to diff against
    exec "vsp " . s:bufname
    set buftype=nofile nobuflisted
    exec "set filetype=" . l:filetype

    " load the file
    let s:diffbuf = bufnr('%')
    exec "read !" . a:prog . " " . l:filename . " | " . g:DiffChanges_patchprog . " " . l:filename
    diffthis

    " return to original
    wincmd p
    diffthis
endfunction

" Close the diff window (if it exists)
function! <SID>DiffClose()
    let l:winnr = bufwinnr(bufnr(s:bufname)) 

    if l:winnr != -1
        exec l:winnr.' wincmd w'
        silent! close
        wincmd p
    endif
endfunction
