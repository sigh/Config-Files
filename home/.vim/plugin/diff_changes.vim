" Diff changes script
" Author: sigh <dilshan.a@gmail.com>
"
" TODO: Handle bdelete on diff buffer
" TODO: Autodetect VCS
" TODO: Create AnyDiffChanges which takes any readwhat string (and expands it
"       first)
" TODO: when deleting delete into blackhole register
" TODO: Make DiffReturn actaully return to the originating diff (give each tab
"       an ID in a variable so that it can be found)

" Set up default globals

" Has this plugin already been loaded?
if exists('loaded_diffchanged')
  finish
endif
let loaded_diffchanged = 1

let s:tmpfile = tempname()
let s:vcsprogs = {}
let s:vcsprogs.git = 'git diff --relative'
let s:vcsprogs.svn = 'svn'

let s:difftabs = {}
let s:max_diff_tab_id = 0

autocmd TabEnter * call <SID>SetTabId() | call <SID>DiffTabCleanup()

" Set up commands

if !exists(':CDiffChanges')
  command! CDiffChanges tabclose
endif

if !exists(':VDiffChanges')
  command! -bang VDiffChanges silent call <SID>DiffStartVCS("<bang>", '')
endif

if !exists(':FileDiffChanges')
  command! -bang FileDiffChanges call <SID>DiffStartFile("<bang>")
endif

if !exists(':NavDiffChanges')
  command! -bang NavDiffChanges call <SID>DiffStartNavPatch("<bang>")
endif

if ! exists(":ReturnDiffChanges")
    command! -bang ReturnDiffChanges silent call <SID>DiffReturn("<bang>")
endif

if ! exists(":VCSAllDiffChanges")
    command! VCSAllDiffChanges silent call <SID>VCSAll()
endif

if ! exists(":VCSUpdateDiffChanges")
    command! VCSUpdateDiffChanges silent call <SID>VCSAllUpdate()
endif

" Return to the diff window (if we got here from diff nav)
" if force is set then then open up a new diff the current file is not a diff
function! <SID>DiffReturn(force)
    CDiffChanges
    if &filetype != 'diff' && a:force != ''
        call <SID>VCSAll()
    endif
endfunction

" Open a new buffer with the diff output from he current VCS
function! <SID>VCSAll()
    " create a new buffer (if required)
    edit! -All-DiffChanges-

    call <SID>VCSAllUpdate()
endfunction

" Update a diff window using VCS
function! <SID>VCSAllUpdate()
    " first try to find the VCS program
    let l:prog = <SID>FindVCS()
    if l:prog == ''
        bdelete
        echoerr "No Version Control System found"
        return
    endif

    " set settings so we can write
    setlocal modifiable
    setlocal noreadonly
    setlocal buftype=nofile
    setlocal nobuflisted

    normal ggdG
    exec "silent read !" . s:vcsprogs[l:prog]
    normal ggdd

    setlocal filetype=diff
    setlocal nomodified
    setlocal readonly
    filetype detect
endfunction

" Special DiffStart functions

" Diff using diff_nav patch infod

function! <SID>DiffStartNavPatch(close)
    if &filetype != 'diff'
        echoerr 'File is not a diff'
        return
    endif
    if ! exists('*GetCurrentDiffPosition')
        echoerr 'diff_nav not installed'
    endif

    let l:diffcontext = GetCurrentDiffPosition()
    if type(l:diffcontext) != type({})
        return
    endif

    " yank the patch
    " TODO: store yank in some other register
    exec 'silent ' . l:diffcontext.patchstart . "," . l:diffcontext.patchend . 'yank'

    " Open a new tab with the file
    exec "tabnew " . l:diffcontext.filename
    exec l:diffcontext.fileposition
    setlocal noreadonly

    let l:command = 'put'
    let l:command = l:command . ' | silent %!patch -s -R -o ' . s:tmpfile . ' ' . expand('%')
    " There must be an empty line at the start of a successful patch for
    " DiffStart to work
    let l:command = l:command . ' ; cat <(echo) ' . s:tmpfile 
    let l:command = l:command . ' ; rm ' . s:tmpfile 

    call <SID>DiffStart(a:close, l:command)
endfunction

" Diff version control system
function! <SID>DiffStartVCS(close, prog)
    if expand('%') == '' || &buftype == 'nofile'
        echoerr 'No file'
        return
    endif

    let l:prog = a:prog

    if l:prog == ''
        let l:prog = <SID>FindVCS()
        if l:prog == ''
            echoerr "No Version Control System found"
            return
        endif
    endif

    let l:filename = expand('%')
    let l:command = "!" . s:vcsprogs[l:prog] . " " . l:filename
    let l:command = l:command . " | patch -s -R -o " . s:tmpfile . " " . l:filename 
    let l:command = l:command . " ; cat " . s:tmpfile 
    let l:command = l:command . " ; rm " . s:tmpfile 

    tab split
    call <SID>DiffStart(a:close, "read " . l:command)
endfunction

" Find which VCS we are in
function! <SID>FindVCS()
    if system('git rev-parse --git-dir 2> /dev/null') != ''
        return 'git'
    elseif isdirectory('.svn')
        return 'svn'
    else
        return ''
    endif
endfunction

" Diff against file on disk
function! <SID>DiffStartFile(close)
    if expand('%') == '' || &buftype == 'nofile'
        echoerr 'No file'
        return
    endif

    tab split
    call <SID>DiffStart(a:close, "read " . expand('%'))
endfunction

" Start diffing the current file
" a:execstring is a command to generate the file to diff against, it is
" expected to add an extra empty line at the start of the file.
function! <SID>DiffStart(close, execstring)
    if has_key(s:difftabs, t:diff_changes_tab_id)
        echoerr 'DiffStart called with a used tab'
        return
    endif

    let l:diff_changes_info = {}
    let s:difftabs[t:diff_changes_tab_id] = l:diff_changes_info
    let l:diff_changes_info.origbuf = bufnr('%')

    let l:filetype = &filetype
    diffthis

    " create buffer to diff against
    vnew
    let l:diff_changes_info.diffbuf = bufnr('%')

    setlocal buftype=nofile nobuflisted
    setlocal noreadonly
    setlocal modifiable
    exec "setlocal filetype=" . l:filetype

    " load the diffed file
    exec "silent " . a:execstring

    " remove the empty first line
    normal ggdd

    " link up the buffers
    diffthis

    " set diff changes window to no be editable
    setlocal readonly
    setlocal nomodifiable

    " close the diff window if we were asked
    if a:close != ""
        wincmd c
    endif

    " return to original buffer
    exec bufwinnr(l:diff_changes_info.origbuf) . " wincmd w"
endfunction

" Go through all tabs and clean them up if they are closed. 
function! <SID>DiffTabCleanup()
    let l:open_tabs = {}
    let l:currenttab = tabpagenr()

    " Find all the currently open tabs
    for i in range(tabpagenr('$'))
        exec 'tabnext ' . (i + 1)
        if exists('t:diff_changes_tab_id')
            let l:open_tabs[t:diff_changes_tab_id] = 1
        endif
    endfor

    exec 'tabnext ' . l:currenttab

    " Remove the diff buffers that associated with closed tabs.
    for [tabid, info] in items(s:difftabs)
        if ! has_key(l:open_tabs, tabid)
            " tabid has been deleted so cleanup the diff buffer
            exec 'bwipeout! ' . info.diffbuf
            unlet s:difftabs[tabid]
        endif
    endfor
endfunction

function! <SID>SetTabId()
    if ! exists('t:diff_changes_tab_id')
        let s:max_diff_tab_id += 1
        let t:diff_changes_tab_id = s:max_diff_tab_id
    endif
endfunction
