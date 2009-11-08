" TODO: open to the correct line

" Give the buffer a name if it has none
if bufname('%') == ""
    " TODO: if r -diff- already exists then what????
    file -diff-
endif

let s:diffbuf = bufnr('%')

" define folds
setlocal foldenable
setlocal foldmethod=expr
setlocal foldexpr=DiffFoldLevel(v:lnum)
setlocal foldlevel=0

function! DiffFoldLevel(linenum)
    let l:line = getline(a:linenum)

    if l:line =~ "^+++ " || l:line =~ "^--- "
        return 0
    endif

    " each individual diff section
    if l:line =~ "^@@"
        return 1
    endif
    if l:line =~ "^[\\t +-]" || len(l:line) == 0
        return 2
    endif

    return 0
endfunction

" commands

if ! exists(":DiffOpenFile")
    command! -bang DiffOpenFile silent call <SID>DiffOpenCurrentFile("<bang>")
endif

if ! exists(":DiffReturn")
    command! DiffReturn silent call <SID>DiffReturn()
endif

" helper functions

" Return to the diff window
function! <SID>DiffReturn()
    if exists(":CDiffChanges")
        CDiffChanges
    endif
    exec "buffer " . s:diffbuf
endfunction

" open the +++ file for the current section
" if whichfile is set to "!" open the --- file
function! <SID>DiffOpenCurrentFile(whichfile)
    let l:filename = <SID>GetCurrentFile(a:whichfile)

    if len(l:filename) > 0
        exec "e " . l:filename
        " setlocal noreadonly
        " setlocal modifiable
    endif
endfunction

" Get the +++ file for the current section in the diff
" if whichfile is set to "!" then get the --- file
function! <SID>GetCurrentFile(whichfile)
    let l:curline = line('.')
    let l:line = l:curline
    let l:text = getline(l:line)
    
    if len(l:text) > 0 && ( l:text =~ "^+++ " || l:text =~ "^--- " || l:text !~ "^[\\t +-]" )
        " move down into a fold 1 area
        while getline(l:line) !~ "^+++ "
            let l:line += 1
        endwhile
    else
        " move up into the top of fold 1 area
        while getline(l:line) !~ "^+++ "
            let l:line -= 1
        endwhile
    endif

    " we are now at the +++ file (modified)

    " if the caller wants the --- file, go there
    if a:whichfile == "!"
        let l:line -= 1
    endif

    return <SID>FindFile(substitute(getline(l:line), "^... \\([^ \\t]*\\).*$", "\\1", ""))
endfunction

function! <SID>FindFile(filename)
    let l:filename = a:filename
    while len(l:filename) > 0 && ! filereadable(l:filename)
        let l:filename = substitute(l:filename, "^[^/]*/*\\(.*\\)$", "\\1", "")
    endwhile
    return l:filename
endfunction
