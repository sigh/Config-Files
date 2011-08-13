" actual file specific setting at end of file

if ! exists('g:diff_nav_loaded')
    let g:diff_nav_loaded = 1

    " Any line that matches this regex is part of the diff proper
    let s:diff_regex = '^$\|^[@\\\t +-]'

    " commands

    if ! exists(":DiffOpenFile")
        command! DiffOpenFile silent call <SID>DiffOpenCurrentFile()
    endif

    " helper functions

    " open file for the current patch
    function! <SID>DiffOpenCurrentFile()
        let l:buf = bufnr('%')
        let l:line = line('.')

        let l:patchstart = <SID>FindStartOfFileDiff(l:line)
        if l:patchstart < 0
            return ''
        endif

        let l:filename = <SID>GetDiffFilename(l:patchstart)
        let l:patchend = <SID>FindEndOfFileDiff(l:patchstart)

        let l:fileposition = 0
        if l:line >= l:patchstart + 2
            let l:fileposition = <SID>FindPositionInFile(l:line)
        endif

        exec "e " . l:filename
        exec l:fileposition

        let b:diff_nav_patch_start = l:patchstart
        let b:diff_nav_patch_end   = l:patchend
        let b:diff_nav_diff_buf    = l:buf

        setlocal noreadonly
    endfunction

    " Find the --- line for the diff containing a:linenum
    function! <SID>FindStartOfFileDiff(linenum)
        let l:line = a:linenum
        let l:lastline = line('$')
        if getline(l:line) !~ s:diff_regex
            " We are in the header, go down until we find the +++
            let l:line = l:line + 1
            while l:line <= l:lastline && getline(l:line) !~ '^--- '
                let l:line = l:line + 1
            endwhile
            if l:line > l:lastline
                return -1
            endif
        elseif getline(l:line) == '^--- ' && getline(l:line + 1) =~ '^@@ '
            " We are on the --- line, do nothing
        elseif getline(l:line) == '^+++ ' && getline(l:line + 1) =~ '^@@ '
            " We are on the +++ line, go up one
            let l:line = l:line - 1
        else
            " We are in the body of the diff, move up until the --- line
            let l:line = l:line - 1
            while l:line >= 1 && ! (getline(l:line) =~ '^--- ' && getline(l:line + 2) =~ '^@@ ')
                let l:line = l:line - 1
            endwhile
            if l:line < 1
                return -1
            endif
        endif
        return l:line
    endfunction

    " Find the last line of a file diff given the first line
    function! <SID>FindEndOfFileDiff(diffstart)
        let l:line = a:diffstart
        let l:lastline = line('$')
        while l:line <= l:lastline && getline(l:line) =~ s:diff_regex
            let l:line = l:line + 1
        endwhile
        return l:line - 1
    endfunction

    " Given the location of the --- line return the filename
    function! <SID>GetDiffFilename(diffstart)
        let l:minusfile = substitute(getline(a:diffstart), '^--- ', '', '')
        let l:plusfile = substitute(getline(a:diffstart + 1), '^+++ ', '', '')
        let [l:filename, l:mode] = <SID>GetFilenameAndMode(l:minusfile, l:plusfile)
        return l:filename
    endfunction

    " Given a - filename and a + filename return what the actual filename is
    function! <SID>GetFilenameAndMode(minusfile, plusfile)
        let l:mode = ''
        let l:filename = ''

        if a:plusfile == '' && a:minusfile == ''
            " pass
        elseif a:minusfile == '' || a:minusfile == '/dev/null'
            " added file
            let l:mode = 'A'
            let l:filename = a:plusfile
        elseif a:plusfile == '' || a:plusfile == '/dev/null'
            " deleted file
            let l:mode = 'D'
            let l:filename = a:minusfile
        else
            " modified file
            let l:mode = 'M'
            let l:filename = a:plusfile
        endif

        " Remove the first part of the path (which is an identifier for the
        " diff)
        let l:filename = substitute(l:filename, '^./', '', '')

        return [l:filename, l:mode]
    endfunction

    " Find the line number in the + file that corresponds to the line a:line
    " in the diff
    function! <SID>FindPositionInFile(line)
        let l:linetext = getline(a:line)

        if l:linetext !~ s:diff_regex
            " Anything in the header maps to line 1
            return 1
        elseif l:linetext =~ '^+++ ' && getline(a:line + 1) =~ '^@@ '
            " +++ is part of the header => maps to line 1
            return 1
        elseif l:linetext =~ '^--- ' && getline(a:line + 2) =~ '^@@ '
            " --- is part of the header => maps to line 1
            return 1
        endif

        " We are in the body of a diff, look up until we find the start of the
        " hunk

        let l:curline = a:line
        let l:hunkoffset = 0

        while l:curline > 0 && getline(l:curline) !~ '^@@ '
            if getline(l:curline) !~ '^[\\-]'
                let l:hunkoffset = l:hunkoffset + 1
            endif
            let l:curline = l:curline - 1
        endwhile

        if getline(l:curline) !~ '^@@ '
            " There was an error, we should have found the start of the hunk
            return 0
        endif

        " We over-counted the lines for hunkoffset, unless a:line was
        " actually the @@ line
        if l:hunkoffset > 0
            let l:hunkoffset = l:hunkoffset - 1
        endif

        let [l:hunkstart, l:hunksize, l:trailing] = <SID>ParseHunkStart(getline(l:curline))

        return l:hunkstart + l:hunkoffset
    endfunction

    " Return [ start line of + file, offset of + file, trailing context ]
    function! <SID>ParseHunkStart(linetext)
        let l:range1 = matchstr(a:linetext, '[^ ]*', 4)
        let l:range2 = matchstr(a:linetext, '[^ ]*', 6 + strlen(l:range1))

        let [l:start, l:size] = <SID>ParseHunkRange(l:range2)

        " return any trailing text
        return [l:start, l:size, substitute(a:linetext, '^@@[^@]*@@', '', '')]
    endfunction

    function! <SID>ParseHunkRange(range)
        if a:range !~ ','
            return [a:range, 0]
        else
            let l:line = matchstr(a:range, "[^,]*")
            let l:size = matchstr(a:range, ".*", strlen(l:line) + 1 )
            return [l:line, l:size]
        endif
    endfunction

    " For a given line number, determine the fold level
    function! DiffNav_DiffFoldLevel(linenum)
        return <SID>DiffNav_DiffFoldLevelHelper(a:linenum, 0)
    endfunction

    " For a given line number, determine the fold level
    " If depth is non-zero then this function has been called recursively.
    function! <SID>DiffNav_DiffFoldLevelHelper(linenum, depth)
        let l:line = getline(a:linenum)

        " Lines that are part of the diff start with +,,-,@,\,tab,space
        if l:line =~ '^+++ ' && getline(a:linenum + 1) =~ '^@@ '
            " pass
        elseif l:line =~ '^--- ' && getline(a:linenum + 2) =~ '^@@ '
            " pass
        elseif l:line =~ '^@@ '
            " each individual diff section
            return '>2'
        elseif l:line =~ s:diff_regex
            return '2'
        endif

        " If we reach here the line is part of the diff header. Determine if
        " it is the start of the header or not.
        " The '^diff --git' check is for diffs output by git, when only
        " permissons changes there is no ---/+++ lines in the header
        if a:linenum == 1 || l:line =~ '^diff --git '
            return '>1'
        elseif a:depth > 0 || <SID>DiffNav_DiffFoldLevelHelper(a:linenum-1, 1) == '2'
            return '>1'
        else
            return '1'
        endif
    endfunction

    " define fold text
    function! DiffNav_DiffFoldText()
        let l:line = getline(v:foldstart)

        if v:foldlevel == 2
            "  @@ lines
            let l:difflines = v:foldend - v:foldstart
            let [l:start, l:size, l:trailing]  = <SID>ParseHunkStart(l:line)
            let l:end = l:start + l:size

            let l:range = 'line ' . l:start . '-' . l:end
            let l:diffsize = '(' . l:difflines . ' line diff)'
            return '      '. l:range . ' ' . l:diffsize . l:trailing
        endif

        " We are at a top-level (file) fold

        let l:linenum = v:foldstart
        let l:lastline = v:foldend

        let l:plusfile = ''
        let l:minusfile = ''

        " The edit type ([A]dded, [D]eleted, [M]odified, [?] unknown)
        let l:mode = 'M'

        " detemine the names of the +++ file and the --- file
        while (l:plusfile == '' || l:minusfile == '') && l:linenum <= l:lastline
            let l:currentline = getline(l:linenum)
            if l:currentline =~ '^--- '
                let l:minusfile = substitute(l:currentline, '^--- ', '', '')
            elseif l:currentline =~ '^+++ '
                let l:plusfile = substitute(l:currentline, '^+++ ', '', '')
            endif
            let l:linenum = l:linenum + 1
        endwhile

        " We didn't find any files, try checking the header
        if l:plusfile == '' && l:minusfile == '' && l:line =~ '^diff --git '
            let l:currentline = substitute(l:line, '^diff --git ', '', '')
            let [l:minusfile, l:plusfile] = split(l:currentline)
            let l:mode = '?'
        endif

        let [l:filename, l:tmpmode] = <SID>GetFilenameAndMode(l:minusfile, l:plusfile)
        if l:mode != '?'
            let l:mode = l:tmpmode
        endif

        let l:difflines = v:foldend - l:linenum + 1
        return l:mode . ' ' . l:filename . ' (' . l:difflines . ' line diff)'
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

