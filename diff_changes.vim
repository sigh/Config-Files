" Diff changes script
" Author: Dilshan Angampitiya 
"
" TODO: Handle bdelete on diff buffer
" TODO: Autodetect VCS
" TODO: Create AnyDiffChanges which takes any readwhat string (and expands it
" first)
" TODO: Use patch

" Set up default globals

" Has this plugin already been loaded?
if exists('loaded_diffchanged')
  finish
endif
let loaded_diffchanged = 1

let s:tmpfile = tempname()

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

if !exists(':VDiffChanges')
  command! -bang VDiffChanges silent call <SID>DiffStartVCS("<bang>", "")
endif

if !exists(':GitDiffChanges')
  command! -bang GitDiffChanges call <SID>DiffStartVCS("<bang>", "git diff")
endif

if !exists(':SvnDiffChanges')
  command! -bang SvnDiffChanges call <SID>DiffStartVCS("<bang>", "svn diff")
endif

if !exists(':FileDiffChanges')
  command! -bang FileDiffChanges call <SID>DiffStartFile("<bang>")
endif

if !exists(':NavDiffChanges')
  command! -bang NavPatchDiffChanges call <SID>DiffStartNavPatch("<bang>")
endif

if ! exists(":DiffReturn")
    command! DiffReturn silent call <SID>DiffReturn()
endif


" Return to the diff window (if we got here from diff nav)
function! <SID>DiffReturn()
    CDiffChanges
    if b:diff_nav_diff_buf
        exec 'buffer ' . b:diff_nav_diff_buf
    endif
endfunction

" Special DiffStart functions

" Diff using diff_nav patch infod

function! <SID>DiffStartNavPatch(close)
    if ! b:diff_nav_diff_buf
        return
    endif

    let l:curbuf = bufnr('%')

    " yank the patch
    let l:yankstring = b:diff_nav_patch_start . "," . b:diff_nav_patch_end . "yank"
    exec "buffer " . b:diff_nav_diff_buf
    exec l:yankstring
    exec "buffer " . l:curbuf

    let l:command = 'put!'
    let l:command = l:command . ' | %!patch -s -R -o ' . s:tmpfile . ' ' . expand('%')
    let l:command = l:command . ' ; cat ' . s:tmpfile 
    let l:command = l:command . ' ; rm ' . s:tmpfile 
    call <SID>DiffStart(a:close, l:command, 0)
endfunction


" Diff version control system
function! <SID>DiffStartVCS(close, prog)
    let l:prog = a:prog

    if l:prog == ""
        let l:prog = <SID>FindVCS()
        if l:prog == ""
            echoerr "No Version Control System found"
            return
        else
            let l:prog = l:prog . " diff"
        endif
    endif

    let l:filename = expand('%')
    let l:command = "!" . l:prog . " " . l:filename
    let l:command = l:command . " | patch -s -R -o " . s:tmpfile . " " . l:filename 
    let l:command = l:command . " ; cat " . s:tmpfile 
    let l:command = l:command . " ; rm " . s:tmpfile 
    call <SID>DiffStart(a:close, "read " . l:command, 1)

endfunction

" Find which VCS we are in
function! <SID>FindVCS()
    if isdirectory('.git')
        return "git"
    elseif isdirectory('.svn')
        return "svn"
    else
        return ""
    endif
endfunction

" Diff against file on disk
function! <SID>DiffStartFile(close)
    call <SID>DiffStart(a:close, "read " . expand('%'), 1)
endfunction


" Start diffing the current file
function! <SID>DiffStart(close, execstring, remove)
    " close current instance if it was running
    call <SID>DiffStop()

    let l:filetype = &filetype
    let s:origbuf = bufnr('%')

	" TODO: Save these as b:diff_changes_* vars
    let s:wrap = &wrap
    let s:foldmethod = &foldmethod
    let s:foldcolumn = &foldcolumn
    let s:foldenable = &foldenable
    let s:foldlevel  = &foldlevel
    diffthis

    " create buffer to diff against
    exec "vsp " . s:bufname
    set buftype=nofile nobuflisted
    set noreadonly
    set modifiable
    exec "set filetype=" . l:filetype

    " load the file
    let s:diffbuf = bufnr('%')
    exec a:execstring
    if a:remove
        normal ggdd " remove the empty first line
    endif

    " error if diffbuf is empty
    if line('$') == 1 && col('$') == 1
        call <SID>DiffStop()
        exec "buffer " . s:origbuf
        redraw
        echomsg "DiffChanges: Empty result (or error occured)"
        return
    endif

    " link up the buffers
    diffthis

    " close the diff window if we were asked
    if a:close == "!"
        wincmd c
    endif

    " return to original buffer
    exec bufwinnr(s:origbuf) . " wincmd w"

endfunction

" Stop diff changes (close the window and remove the buffer)
function! <SID>DiffStop()
    if s:diffbuf != -1
        " close diff buffer
        call <SID>DiffClose()
        exec "bwipeout! " . s:diffbuf
        let s:diffbuf = -1

        let l:curwin = winnr()

        " reset settings in original buffer
        let l:winnr = bufwinnr(s:origbuf)
        if l:winnr != -1
            exec l:winnr . "wincmd w"
        else
            exec "buffer " . s:origbuf
        endif

		set nodiff
        let &wrap = s:wrap
        let &foldmethod = s:foldmethod 
        let &foldcolumn = s:foldcolumn 
        let &foldenable = s:foldenable
        let &foldlevel  = s:foldlevel

        exec l:curwin . "wincmd w"
    endif   
endfunction

" Open the diff window again
function! <SID>DiffOpen()
    " if it is already open we can finish
    if bufwinnr(s:diffbuf) != -1
        return
    endif

    " can't do anything if it hasn't been started
    if s:diffbuf == -1
        return
    endif

    let l:curbuf = bufnr('%')

    let l:winnr = bufwinnr(s:origbuf)
    if l:winnr != -1
        " we only do something if the buffer is visible
        exec l:winnr . "wincmd w"
        exec "vsp #" . s:diffbuf
    endif

    " return to original buffer
    exec bufwinnr(l:curbuf) . " wincmd w"
endfunction

" Close the diff window (if it exists)
function! <SID>DiffClose()
    " save the current buffer
    let l:curbuf = bufnr('%')

    if s:diffbuf == l:curbuf
        " if we are in the diff buf, just close it
        silent! close
    else
        " close the diff window if it's open
        let l:winnr = bufwinnr(s:diffbuf) 
        if l:winnr != -1
            exec l:winnr.' wincmd w'
            silent! close
        endif

        " return to current window
        exec bufwinnr(l:curbuf) . "wincmd w"
    endif
endfunction

" Toggle diff buffer
function! <SID>DiffToggle()
    if bufwinnr(s:diffbuf) == -1
        call <SID>DiffOpen()
    else
        call <SID>DiffClose()
    endif
endfunction

""""
" Here be unfinished dragons
""""

" Get diff window for bufnr ignoring window winignore
function! <SID>GetDiffWindow(bufnr, winignore)
    let l:curwin = winnr()

    " first check if the window is visible
    let l:winnr = <SID>GetVisibleDiffWindow(a:bufnr)
    if l:winnr != -1 && l:winnr != a:winignore
        return l:winnr
    endif

    " iterate through the windows and check if any match
    let l:winnr = winnr('$')
    while l:winnr > 0
        if l:winnr != a:winignore
            let l:curbuf = bufnr('%')

            " for each window switch to the target buffer and check
            " the diff value
            exec l:winnr . "wincmd w"
            exec "buffer " . a:bufnr

            if &diff
                " found it: reset everything and return
                exec "buffer " . l:curbuf
                exec l:curwin . "wincmd w"
                return l:winnr
            endif

            exec "buffer " . l:curbuf
            let l:winnr = l:winnr - 1
        endif
    endwhile

    exec l:curwin . "wincmd w"
    return -1
endfunction

" Return the diff window of bufnr (if visible)
function! <SID>GetVisibleDiffWindow(bufnr)
    let l:winnr = bufwinnr(a:bufnr)
    if l:winnr != -1
        if getwinvar(l:winnr, "&diff")
            return l:winnr
        endif
    endif
    return -1
endfunction
