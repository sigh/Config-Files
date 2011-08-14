" actual file specific setting at end of file

if ! exists('g:diff_nav_loaded')
    let g:diff_nav_loaded = 1

    " Any line that matches this regex is part of the diff proper
    let s:diff_regex = '^$\|^[@\\\t +-]'

    " commands

    if ! exists(":DiffOpenFile")
        command! DiffOpenFile silent call <SID>DiffOpenCurrentFile()
    endif

    function! GetCurrentDiffPosition()
        let l:buf = bufnr('%')
        let l:line = line('.')

        let l:patchstart = <SID>FindStartOfPatch(l:line)
        if l:patchstart < 0
            return ''
        endif

        let l:filename = <SID>GetPatchFilename(l:patchstart)
        let l:patchend = <SID>FindEndOfPatch(l:patchstart)

        let l:fileposition = 0
        if l:line >= l:patchstart + 2
            let l:fileposition = <SID>FindPositionInFile(l:line)
        endif

        let l:diffcontext = {}
        let l:diffcontext.filename = l:filename
        let l:diffcontext.patchstart = l:patchstart
        let l:diffcontext.patchend = l:patchend
        let l:diffcontext.fileposition = l:fileposition

        return l:diffcontext
    endfunction

    " helper functions

    " open file for the current patch
    function! <SID>DiffOpenCurrentFile()
        let l:diffcontext = GetCurrentDiffPosition()

        if type(l:diffcontext) != type({})
            return
        endif

        exec "e " . l:diffcontext.filename
        exec l:diffcontext.fileposition

        setlocal noreadonly
    endfunction

    " Find the --- line for the patch containing a:line
    function! <SID>FindStartOfPatch(line)
        let l:curline = a:line
        let l:lastline = line('$')
        if getline(l:curline) !~ s:diff_regex
            " We are in the header, go down until we find the +++
            let l:curline = l:curline + 1
            while l:curline <= l:lastline && getline(l:curline) !~ '^--- '
                let l:curline += 1
            endwhile
            if l:curline > l:lastline
                return -1
            endif
        elseif getline(l:curline) == '^--- ' && getline(l:curline + 1) =~ '^@@ '
            " We are on the --- line, do nothing
        elseif getline(l:curline) == '^+++ ' && getline(l:curline + 1) =~ '^@@ '
            " We are on the +++ line, go up one
            let l:curline -= 1
        else
            " We are in the body of the patch, move up until the --- line
            let l:curline = l:curline - 1
            while l:curline >= 1 && ! (getline(l:curline) =~ '^--- ' && getline(l:curline + 2) =~ '^@@ ')
                let l:curline -= 1
            endwhile
            if l:curline < 1
                return -1
            endif
        endif

        return l:curline
    endfunction

    " Find the last line of a patch given the first line
    function! <SID>FindEndOfPatch(patchstart)
        let l:line = a:patchstart
        let l:lastline = line('$')
        while l:line <= l:lastline && getline(l:line) =~ s:diff_regex
            let l:line += 1
        endwhile
        return l:line - 1
    endfunction

    " Given the location of the --- line return the filename
    function! <SID>GetPatchFilename(patchstart)
        let l:minusfile = substitute(getline(a:patchstart), '^--- ', '', '')
        let l:plusfile = substitute(getline(a:patchstart + 1), '^+++ ', '', '')
        let [l:filename, l:mode] = <SID>GetFilenameAndMode(l:minusfile, l:plusfile)
        return l:filename
    endfunction

    " Given a - filename and a + filename return what the actual filename is
    " modes ([A]dded, [D]eleted, [M]odified, [R]enamed [?] unknown)
    function! <SID>GetFilenameAndMode(minusfile, plusfile)
        let l:mode = ''
        let l:filename = ''

        " Remove the first part of the path (which git puts there)
        " This can break normals diffs for one letter paths, but that's less
        " common than git.
        let l:plusfile = substitute(a:plusfile, '^./', '', '')
        let l:minusfile = substitute(a:minusfile, '^./', '', '')

        " Remove everything after a tab (will break some files with tabs)
        let l:plusfile = substitute(l:plusfile, '\t\+[^\t]\+$', '', '')
        let l:minusfile = substitute(l:minusfile, '\t\+[^\t]\+$', '', '')

        if l:plusfile == '' && l:minusfile == ''
            " pass
        elseif l:minusfile == '' || l:minusfile == '/dev/null'
            " added file
            let l:mode = 'A'
            let l:filename = l:plusfile
        elseif l:plusfile == '' || l:plusfile == '/dev/null'
            " deleted file
            let l:mode = 'D'
            let l:filename = l:minusfile
        elseif l:plusfile != l:minusfile
            let l:mode = 'R ' . l:minusfile . ' =>'
            let l:filename = l:plusfile
        else
            " modified file
            let l:mode = 'M'
            let l:filename = l:plusfile
        endif

        return [l:filename, l:mode]
    endfunction

    " Find the line number in the + file that corresponds to the line a:line
    " in the patch
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

        " We are in the body of a patch, look up until we find the start of the
        " hunk

        let l:curline = a:line
        let l:hunkoffset = 0

        while l:curline > 0 && getline(l:curline) !~ '^@@ '
            if getline(l:curline) !~ '^[\\-]'
                let l:hunkoffset = l:hunkoffset + 1
            endif
            let l:curline -= 1
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
    function! DiffNav_DiffFoldLevel(line)
        return <SID>DiffNav_DiffFoldLevelHelper(a:line, 0)
    endfunction

    " For a given line number, determine the fold level
    " If depth is non-zero then this function has been called recursively.
    function! <SID>DiffNav_DiffFoldLevelHelper(line, depth)
        let l:linetext = getline(a:line)

        " Lines that are part of the diff start with +,,-,@,\,tab,space
        if l:linetext =~ '^+++ ' && getline(a:line + 1) =~ '^@@ '
            " pass
        elseif l:linetext =~ '^--- ' && getline(a:line + 2) =~ '^@@ '
            " pass
        elseif l:linetext =~ '^@@ '
            " each individual hunk
            return '>2'
        elseif l:linetext =~ s:diff_regex
            return '2'
        endif

        " If we reach here the line is part of the patch header. Determine if
        " it is the start of the header or not.
        " The '^diff --git' check is for diffs output by git, when only
        " permissons changes there is no ---/+++ lines in the header
        if a:line == 1 || l:linetext =~ '^diff --git '
            return '>1'
        elseif a:depth > 0 || <SID>DiffNav_DiffFoldLevelHelper(a:line-1, 1) == '2'
            return '>1'
        else
            return '1'
        endif
    endfunction

    " define fold text
    function! DiffNav_DiffFoldText()
        let l:linetext = getline(v:foldstart)

        if v:foldlevel == 2
            "  @@ lines
            let l:hunksize = v:foldend - v:foldstart
            let [l:start, l:size, l:trailing]  = <SID>ParseHunkStart(l:linetext)
            let l:end = l:start + l:size

            let l:rangedesc = 'line ' . l:start . '-' . l:end
            let l:sizedesc = '(' . l:hunksize . ' lines)'
            return '      '. l:rangedesc . ' ' . l:sizedesc . l:trailing
        endif

        " We are at a top-level (file) fold

        let l:curline = v:foldstart
        let l:lastline = v:foldend

        let l:plusfile = ''
        let l:minusfile = ''

        let l:mode = 'M'

        " detemine the names of the +++ file and the --- file
        while (l:plusfile == '' || l:minusfile == '') && l:curline <= l:lastline
            let l:curlinetext = getline(l:curline)
            if l:curlinetext =~ '^--- '
                let l:minusfile = substitute(l:curlinetext, '^--- ', '', '')
            elseif l:curlinetext =~ '^+++ '
                let l:plusfile = substitute(l:curlinetext, '^+++ ', '', '')
            endif
            let l:curline += 1
        endwhile

        " We didn't find any files, try checking the header
        if l:plusfile == '' && l:minusfile == '' && l:linetext =~ '^diff --git '
            let l:filenames = substitute(l:linetext, '^diff --git ', '', '')
            let [l:minusfile, l:plusfile] = split(l:filenames)
            let l:mode = '?'
        endif

        let [l:filename, l:tmpmode] = <SID>GetFilenameAndMode(l:minusfile, l:plusfile)
        if l:mode != '?'
            let l:mode = l:tmpmode
        endif

        let l:patchsize = v:foldend - l:curline + 1
        return l:mode . ' ' . l:filename . ' (' . l:patchsize . ' lines)'
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

