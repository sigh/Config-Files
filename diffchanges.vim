" Diff changes script
" Author: Dilshan Angampitiya 
"
" TODO: Handle bdelete on diff buffer
" TODO: Autodetect VCS

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
let s:origbuf = -1
let s:bufname = "-DiffChanges-"

" Set up commands


if !exists(':CDiffChanges')
  command! CDiffChanges silent call <SID>DiffStop()
endif

if !exists(':HDiffChanges')
  command! HDiffChanges silent call <SID>DiffClose()
endif

if !exists(':SDiffChanges')
  command! SDiffChanges silent call <SID>DiffOpen()
endif

if !exists(':TDiffChanges')
  command! TDiffChanges silent call <SID>DiffToggle()
endif

if !exists(':GitDiffChanges')
  command! -bang GitDiffChanges silent call <SID>DiffStartVCS("<bang>", "git diff")
endif

if !exists(':FileDiffChanges')
  command! -bang FileDiffChanges silent call <SID>DiffStartFile("<bang>")
endif

" Special DiffStart functions

" Diff version control system
function! <SID>DiffStartVCS(close, prog)
    let l:filename = expand('%')
    call <SID>DiffStart(a:close, "!" . a:prog . " " . l:filename . " | " . g:DiffChanges_patchprog . " " . l:filename)
endfunction

" Diff against file on disk
function! <SID>DiffStartFile(close)
    call <SID>DiffStart(a:close, expand('%'))
endfunction


" Start diffing the current file
function! <SID>DiffStart(close, readwhat)
    " close current instance if it was running
    call <SID>DiffStop()

    let l:filetype = &filetype
    let s:diff = 1
    let s:origbuf = bufnr('%')

    " create buffer to diff against
    exec "vsp " . s:bufname
    set buftype=nofile nobuflisted
    exec "set filetype=" . l:filetype

    " load the file
    let s:diffbuf = bufnr('%')
    exec "read " . a:readwhat
    normal ggdd " remove the empty first line
    diffthis

    " return to original
    if a:close == "!"
        wincmd c
    else
        wincmd p
    endif

    diffthis
endfunction

" Stop diff changes (close the window and remove the buffer)
function! <SID>DiffStop()
    if s:diffbuf != -1
        " close diff buffer
        call <SID>DiffClose()
        exec "bwipeout! " . s:diffbuf
        let s:diffbuf = -1

        " reset settings in original buffer
        exec "buffer " . s:origbuf
        diffoff
        " TODO: reset diff, scrollbind, scrollopt, wrap, foldmethod,
        " foldcolumn
        exec "buffer " . s:origbuf
    endif   
endfunction

" Open the diff window again
function! <SID>DiffOpen()
    " if it is already open we can finish
    if bufwinnr(bufnr(s:bufname)) != -1
        return
    endif

    " can't do anything if it hasn't been started
    if s:diffbuf == -1
        return
    endif

    exec "buffer " . s:origbuf
    exec "vsp #" . s:diffbuf
    wincmd p
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

" Toggle diff buffer
function! <SID>DiffToggle()
    if bufwinnr(bufnr(s:bufname)) == -1
        call <SID>DiffOpen()
    else
        call <SID>DiffClose()
    endif
endfunction
