" delete all blank lines at the start of the file
1;/./-1d

" Clear the undo history (so that we can't undo past our modifications).
" (From :h clear-undo)
let old_undolevels = &undolevels
set undolevels=-1
exe "normal a \<BS>\<Esc>"
let &undolevels = old_undolevels
unlet old_undolevels

" Don't consider the file modified.
set nomod

set nocp
set so=0
set hlsearch
set incsearch
nohlsearch
" Don't remember file names and positions
set viminfo=
set nows

" no swap file and smaller cmd
set noswf
set cmdheight=1
set nolist

set mouse=a
set ttymouse=xterm2

function! Selector(type, ...)
    if a:0  " Invoked from Visual mode, use '< and '> marks.
        return "`<" . a:type . "`>"
    elseif a:type == 'line'
        return "'[V']"
    elseif a:type == 'block'
        return "`[\<C-V>`]"
    else
        return "`[v`]"
    endif
endfunction

if $OUTPUT_FILE != ''
    " S{motion} outputs the text and quits.
    function! OutputCommand(type, ...)
        let reg_save = @@
        let selector = ""
        if a:0
            let selector = Selector(a:type, a:0)
        else
            let selector = Selector(a:type)
        endif
        silent exec "normal! " . selector . "y"
        if strlen(@@) > 0
            enew
            normal! p
            w! $OUTPUT_FILE
            q!
        else
            let @@ = reg_save
            echoerr "Empty selection"
        endif
    endfunction

    nnoremap <silent> S :set opfunc=OutputCommand<CR>g@
    vnoremap <silent> S :<C-U>call OutputCommand(visualmode(), 1)<CR>
else
    " Don't want to confuse myself
    nnoremap <silent> S <Nop>
    vnoremap <silent> S <Nop>
endif

" Q{motion} escapes the text for the shell.
function! ShellEscape(type, ...)
    let reg_save = @@
    let selector = ""
    if a:0
        let selector = Selector(a:type, a:0)
    else
        let selector = Selector(a:type)
    endif
    silent exec "normal! " . selector . "d"
    silent exec "normal! i" . shellescape(@@)
    let @@ = reg_save
endfunction
nnoremap <silent> Q :set opfunc=ShellEscape<CR>g@
vnoremap <silent> Q :<C-U>call ShellEscape(visualmode(), 1)<CR>

" [count]- goes to command with history number count
function! s:GoToCommand()
    let match = search('^' . v:count1 . ' \$', 'cw')
    if match != 0
        foldopen
    endif
endfunction
noremap <unique> <script> <silent> - :<C-U>call <SID>GoToCommand()<CR>

" Output syntax highlighted file as html
map <Leader>h :call tohtml#Convert2HTML(1, line('$'))<Bar>set nomodified<CR>
let g:html_ignore_folding=1
let g:whole_filler=1
let g:number_lines=0

function FoldLevel(line)
  if getline(a:line) =~ '^\[\d\d:\d\d\] \[\d\+\] dilshan@[^:]\+:'
    return '>1'
  else
    return '1'
  endif
endfunction

function DiffFoldText()
  " The timestamp on the command line.
  let l:time = split(getline(v:foldstart))[0]

  " The command name.
  let l:linetext = getline(v:foldstart + 1)

  " The number of lines in the command output.
  let l:numlines = v:foldend - v:foldstart - 1

  " If the command name is fg then the real command will be printed next line.
  if l:linetext =~ '^\d\+ \$ \s*\(fg\>\|%\)'
    let l:linetext = substitute(l:linetext, '\$ .*', '$ ' . s:FindFGText(v:foldstart + 2, v:foldend), '')
    let l:numlines -= 1
  endif

  let l:linecount = max([l:numlines,0])
  return l:time . ' (' . l:linecount . ')' . repeat(' ', 5 - strlen(l:linecount)) . l:linetext
endfunction

" Find the first non-blank line in the fold
function s:FindFGText(startlineno, endlineno)
  let lineno = a:startlineno
  while lineno <= a:endlineno
    let line = getline(lineno)
    if line != ''
      return line
    endif
    let lineno += 1
  endwhile
  return '??'
endfunction

" define folds
set foldenable
set foldmethod=expr
set foldexpr=FoldLevel(v:lnum)
set foldtext=DiffFoldText()
set foldlevel=0

" all filchars blank
set fillchars=vert:\ ,stl:\ ,stlnc:\ ,diff:\ ,fold:\ 

" Syntax highlighting
syntax reset
syn match command '^\[\d\d:\d\d\] \[\d\+\] dilshan@[^:]\+:.*\n\d\+ \$'
hi link command Comment

if &term == "screen-256color" || &term == "xterm-256color"
    set t_Co=256
    colorscheme lucius_mod
    hi Normal       ctermfg=0      ctermbg=15        cterm=none
    hi Comment      ctermfg=2
    hi User1        ctermfg=3      ctermbg=237       cterm=bold
else
    set t_Co=16
    set background=light
    colorscheme peachpuff_mod
    hi Comment ctermfg=2
    hi Folded ctermfg=4 ctermbg=8
    hi FoldColumn ctermfg=4 ctermbg=7
    hi User1 ctermfg=3 ctermbg=0
endif

if &term =~ '^screen'
    " tmux will send xterm-style keys when its xterm-keys option is on
    execute "set <xUp>=\e[1;*A"
    execute "set <xDown>=\e[1;*B"
    execute "set <xRight>=\e[1;*C"
    execute "set <xLeft>=\e[1;*D"
endif

function ToggleFold()
  if foldclosed('.') == -1
    foldclose
  else
    foldopen
  endif
endfunction

" mouse clicks opens folds
nnoremap <silent> <LeftRelease> :foldopen<CR>

" double mouse click closes fold.
nnoremap <silent> <2-LeftMouse> :foldclose<CR>

" Put cursor at end and display position
if &wrap
  noremap <SID>L L0zb<CR>
else
  noremap <SID>L Lg0zb<CR>
endif

noremap q <Esc>:q!<CR>

function MyStatusLine()
  let l:start = '[scrollback]%<'
  let l:end = ' %l/%L [%p%%] %v [%b,0x%B]'
  if foldclosed('.') >= 0 || bufnr('%') != 1
    return l:start . '%=' . l:end
  endif

  let l:save_cursor = getpos('.')
  foldclose
  let l:text = foldtextresult(foldclosed('.'))
  let l:lastline = foldclosedend('.')
  foldopen
  call setpos('.', l:save_cursor)

  let l:parts = matchlist(l:text, '\$\(.*\) (\(\d\+\) lines)$')
  if len(l:parts) > 0
      let l:cmd = l:parts[1]
      let l:lines = l:parts[2]

      " Calculate the current line. Lines in the header are all line 0.
      let l:curline = l:lines - (l:lastline - line('.'))
      if l:curline < 0
        let l:curline = 0
      endif

      let l:percent = l:curline <= 0 ? 0 : (l:lines == 1 ? 100 : (l:curline-1) * 100 / (l:lines - 1))

      return l:start . '%1*' . l:cmd . '%*%= ' . l:curline . '/' . l:lines . ' [' . l:percent . '%%]' . l:end
    else
      return l:start . '%=' .l:end
    fi
endfunction

" Set the status line
set statusline=%!MyStatusLine()
set laststatus=2

" Go to the end of a buffer then go up to the previous command.
normal GLk

" Ensure that we can see as much of the current command as possible.
normal zt

" Find the start of the output, if possible
let start_line = min([foldclosedend('.'), line('.') + 2])

" Open the fold
normal zO

" Go to our desired start line
exec start_line

let unused_space = winheight(0) - winline() - (line('$') - line('.'))
if unused_space > 0
  exec "normal " . unused_space . "\<C-Y>"
endif
