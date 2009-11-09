" TODO: open to the correct line

" Give the buffer a name if it has none
" if bufname('%') == ''
"     " TODO: if r -diff- already exists then what????
"     file -diff-
" endif

" define folds
setlocal foldenable
setlocal foldmethod=expr
setlocal foldexpr=DiffFoldLevel(v:lnum)
setlocal foldlevel=0
setlocal tabstop=8
setlocal softtabstop=0
setlocal noexpandtab

function! DiffFoldLevel(linenum)
    let l:line = getline(a:linenum)

    if l:line =~ '^+++ ' || l:line =~ '^--- '
        return 0
    endif

    " each individual diff section
    if l:line =~ '^@@'
        return 1
    endif
    if l:line =~ '^[\\\t +-]' || strlen(l:line) == 0
        return 2
    endif

    return 0
endfunction

" commands

if ! exists(":DiffOpenFile")
    command! DiffOpenFile silent call <SID>DiffOpenCurrentFile()
endif

" helper functions

" open the +++ file for the current section
" if whichfile is set to "!" open the --- file
function! <SID>DiffOpenCurrentFile()
    let l:buf = bufnr('%')
    let l:filename = <SID>ParseDiff()

    " return empty string on error
    if l:filename == ''
        return
    endif

    exec "e " . l:filename
    exec string(s:file_line)

    let b:diff_nav_patch_start = s:patch_start - 2 " include headers
    let b:diff_nav_patch_end   = s:patch_end
    let b:diff_nav_diff_buf    = l:buf

    " TODO: set these appropriately
    " setlocal noreadonly
    " setlocal modifiable
endfunction

" Parse the diff and return the filename where the cursor is
" but patch_start, patch_end and file_line into script variables
function! <SID>ParseDiff()
    let l:curline = line('.')
    let l:line = 1    
    let l:lastline = line('$')

    let l:curfile = ''
    let l:file_line = 1

    while l:line <= l:curline " file loop
        " go down until the +++ line
        while getline(l:line) !~ '^+++ ' && l:line < l:lastline
            let l:line = l:line + 1
        endwhile
                
        " return empty string on error
        if l:line == l:lastline
            return ''
        endif

        " get the current file name
        let l:curfile = <SID>ParseFileLine(getline(l:line))

        let l:line = l:line + 1

        " now at @@
        let l:patch_start = l:line

        while getline(l:line) =~ '^@@ '      " patch loop
            let l:range = <SID>ParsePatchStart(getline(l:line))

            " get range data
            let l:pos = 0
            let l:line1 = matchstr(l:range,'[^,]*',l:pos)
            let l:pos = l:pos + strlen(l:line1) + 1
            let l:offset1 = matchstr(l:range,'[^,]*',l:pos)
            let l:pos = l:pos + strlen(l:offset1) + 1
            let l:line2 = matchstr(l:range,'[^,]*',l:pos)
            let l:pos = l:pos + strlen(l:line2) + 1
            let l:offset2 = matchstr(l:range,'[^,]*',l:pos)

            " convert to ints
            let l:line1 = str2nr(l:line1)
            let l:end1 = str2nr(l:offset1) + l:line1
            let l:line2 = str2nr(l:line2)
            let l:end2 = str2nr(l:offset2) + l:line2

            if l:line == l:curline
                let l:file_line = l:line2
            endif

            let l:line = l:line + 1

            " loop over lines in patch part
            while ( l:line1 < l:end1 || l:line2 < l:end2 ) && l:line <= l:lastline
                if l:line == l:curline
                    let l:file_line = l:line2
                endif

                let l:char = getline(l:line)[0]

                if l:char != '+'
                    let l:line1 = l:line1 + 1
                endif
                if l:char != '-'
                    let l:line2 = l:line2 + 1
                endif

                let l:line = l:line + 1
            endwhile
        endwhile

        " check for \Newline 
        if getline(l:line) =~ '^\\ '
            if l:line == l:curline
                let l:file_line = '$'
            endif
            let l:line = l:line + 1
        endif

        let l:patch_end = l:line - 1
    endwhile

    " return empty string on error
    if l:curfile == ''
        return ''
    endif

    let s:patch_start = l:patch_start
    let s:patch_end   = l:patch_end
    let s:file_line   = l:file_line

    return l:curfile
endfunction

function! <SID>ParsePatchStart(line)
    " check if line is valid

    let l:range1 = matchstr(a:line, '[^ ]*', 4)
    let l:range2 = matchstr(a:line, '[^ ]*', 6 + strlen(l:range1))

    let l:range1_str = <SID>ParseRange(l:range1)
    let l:range2_str = <SID>ParseRange(l:range2)

    return l:range1_str . ',' . l:range2_str 
endfunction

function! <SID>ParseRange(range)
    if a:range !~ ','
        return a:range . ',0'
    endif

    return a:range
endfunction

function! <SID>ParseFileLine(fileline)
    let l:filename = substitute(a:fileline, '^+++ \([^ \t]*\).*$', '\1', '')

    " If the above didn't match, return empty string for error
    if l:filename == a:fileline
        return ''
    endif

    while l:filename != '' && ! filereadable(l:filename)
        let l:filename = substitute(l:filename, '^[^/]*/*\(.*\)$', '\1', '')
    endwhile
    
    return l:filename
endfunction

