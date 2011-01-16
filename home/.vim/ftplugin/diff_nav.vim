" actual file specific setting at end of file

if ! exists('g:diff_nav_loaded')
    let g:diff_nav_loaded = 1

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
        exec s:ParseDiff_file_line

        let b:diff_nav_patch_start = s:ParseDiff_patch_start
        let b:diff_nav_patch_end   = s:ParseDiff_patch_end
        let b:diff_nav_diff_buf    = l:buf

        " TODO: set these appropriately
        " setlocal noreadonly
        setlocal modifiable
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
                call <SID>ParsePatchStart(getline(l:line))

                let l:line1 = s:ParsePatchStart_line1
                let l:line2 = s:ParsePatchStart_line2
                let l:end1 = l:line1 + s:ParsePatchStart_offset1
                let l:end2 = l:line2 + s:ParsePatchStart_offset2

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

        let s:ParseDiff_patch_start = l:patch_start - 2 " include headers
        let s:ParseDiff_patch_end   = l:patch_end
        let s:ParseDiff_file_line   = l:file_line

        return l:curfile
    endfunction

    function! <SID>ParsePatchStart(line)
        " check if line is valid

        let l:range1 = matchstr(a:line, '[^ ]*', 4)
        let l:range2 = matchstr(a:line, '[^ ]*', 6 + strlen(l:range1))

        call <SID>ParseRange(l:range1)
        let s:ParsePatchStart_line1   = s:ParseRange_line
        let s:ParsePatchStart_offset1 = s:ParseRange_offset

        call <SID>ParseRange(l:range2)
        let s:ParsePatchStart_line2   = s:ParseRange_line
        let s:ParsePatchStart_offset2 = s:ParseRange_offset

        " return any trailing text
        return substitute(a:line, '^@@[^@]*@@', '', '')
    endfunction

    function! <SID>ParseRange(range)
        if a:range !~ ','
            let s:ParseRange_line   = a:range
            let s:ParseRange_offset = 0
        else
            let s:ParseRange_line   = matchstr(a:range, "[^,]*")
            let s:ParseRange_offset = matchstr(a:range, ".*", strlen(s:ParseRange_line) + 1 )
        endif
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

    " define fold levels

    function! DiffNav_DiffFoldLevel(linenum)
        return <SID>DiffNav_DiffFoldLevelHelper(a:linenum, 0)
    endfunction

    function! <SID>DiffNav_DiffFoldLevelHelper(linenum, depth)
        let l:line = getline(a:linenum)

        if l:line =~ '^+++ ' || l:line =~ '^--- '
            " pass
        elseif l:line =~ '^@@ '
            " each individual diff section
            return ">2"
        elseif l:line =~ '^[\\\t +-]' || strlen(l:line) == 0
            return 2
        endif
        
        if a:depth > 0 || a:linenum == 1 || <SID>DiffNav_DiffFoldLevelHelper(a:linenum-1, 1) == 2
            return ">1"
        else
            return "1"
        endif
    endfunction

    " define fold text

    function! DiffNav_DiffFoldText()
        let l:line = getline(v:foldstart)
        
        if v:foldlevel == 2
            "  @@ lines
            let l:difflines = v:foldend - v:foldstart
            let l:trailing  = <SID>ParsePatchStart(l:line)
            let l:start = s:ParsePatchStart_line2
            let l:end   = l:start + s:ParsePatchStart_offset2 - 1

            let l:range = 'line ' . l:start . '-' . l:end
            let l:diffsize = '(' . l:difflines . ' line diff)'
            return '      '. l:range . ' ' . l:diffsize . l:trailing 
        endif

        " file fold
        let l:linenum = v:foldstart
        let l:lastline = line('$')

        " go down until we find a +++ line
        while getline(l:linenum) !~ '^+++ ' && l:linenum < l:lastline
            let l:linenum = l:linenum + 1
        endwhile

        if l:linenum == l:lastline
            " no +++ line found: just print the line
            return l:line
        endif

        let l:text = substitute(getline(l:linenum), '^+++ ', '', '')
        let l:difflines = v:foldend - l:linenum
        return l:text . ' (' . l:difflines . ' line diff)'
    endfunction
endif

" define folds
setlocal foldenable
setlocal foldmethod=expr
setlocal foldexpr=DiffNav_DiffFoldLevel(v:lnum)
setlocal foldtext=DiffNav_DiffFoldText()
setlocal foldlevel=0
setlocal tabstop=8
setlocal softtabstop=0
setlocal noexpandtab
setlocal readonly
setlocal nomodifiable

