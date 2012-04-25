" Based on Tabname plugin: http://www.vim.org/scripts/script.php?script_id=1678
" and buftabs plugin: http://www.vim.org/scripts/script.php?script_id=1664

if exists('tabline_buffers_loaded')
    finish
endif
let tabline_buffers_loaded = 1

""""""""""""""""""""""""
" Tab name customization
""""""""""""""""""""""""

function! s:SetTabName(name)
    let t:tab_name = a:name
    for win_number in range(1, winnr('$'))
        call setwinvar(win_number, "tab_win_name", a:name)
    endfor
endfunction

function! s:RemoveTabName()
    for win_number in range(1, winnr('$'))
        call setwinvar(win_number, "tab_win_name", '')
    endfor
    unlet t:tab_name
endfunction

function! s:TabWinEnter()
    if exists('t:tab_name')
        call setwinvar(winnr(), "tab_win_name", t:tab_name)
    endif
endfunction

function! s:GetTabName(number)
    return gettabwinvar(a:number, 1, 'tab_win_name')
endfunction

"""""""""""""
" Tab display
"""""""""""""

function! s:TabString()
    " Don't display tabs if there is only one
    if tabpagenr('$') == 1
        return ['', 0]
    endif

    let line = ''
    let len = 0
    for i in range(1, tabpagenr('$'))
        let caption = '[' . i . ']'
        let name = ' ' . s:GetTabName(i) . ' '
        let hl = '%#TabLine#'
        if i == tabpagenr()
            let hl = '%#TabLineSel#'
        endif

        let line .= '%' . i . 'T%#String#' . caption . hl . name . '%#TabLineFill#%T'
        let len += strlen(caption) + strlen(name)
    endfor

    return [line, len]
endfunction

"""""""""""""
" Buffer list
"""""""""""""

function! s:CreateBufferList(deleted_buf)
  let s:buffers = []
  let names = {}
  for i in range(1, bufnr('$'))
    let text = ''
    if buflisted(i) && getbufvar(i, "&modifiable") && a:deleted_buf != i
      let text = fnamemodify(bufname(i), ":t")
      if text == '' " Hashes can't handle the empty string.
        continue
      endif

      let text = substitute(text, '[[\]()]', '?', '')
      if !has_key(names, text)
        let names[text] = []
      endif
      call add(names[text], i)
    endif
    call add(s:buffers, text)
  endfor

  " Dedupe names
  for [key, values] in items(names)
    if len(values) > 1
      for [i, name] in s:DedupeNames(values)
        let s:buffers[i-1] = name
      endfor
    endif
  endfor
endfunction

function! s:DedupeNames(buffers)
  " TODO(dilshan): Do better deduping - for now this just adds the first letter
  " of the parent directory, if it exists.
  let names = []
  for b in a:buffers
    let value = bufname(b)
    let name = fnamemodify(value, ':t')
    if name == value
      call add(names, [b, name])
    else
      let dir = fnamemodify(pathshorten(fnamemodify(value, ':~:.')), ':h:t')
      call add(names, [b, dir . '/' . name])
    endif
  endfor
  return names
endfunction

function! s:BufferString(width)
  let current_buffer = bufnr('%')

  let i = 0
  let items = []
  for item in s:buffers
    let i = i + 1
    if item == ''
      continue
    endif
    let desc = i . ':' . item
    if i == current_buffer
      let desc = "( " . desc . ' )'
    elseif bufwinnr(i) != -1
      let desc = '[' . desc . ']'
    endif
    call add(items, desc)
  endfor

  let line = join(items, ' ')
  if strlen(line) > a:width
    " If the resulting list is too long to fit on the screen, chop
    " out the appropriate part
    let from = 0
    " The trailing space is added so that there will always be three parts to
    " the split.
    let parts = split(line . ' ', '[()]')
    if len(parts) == 3
      let start = strlen(parts[0]) + 1
      let end = strlen(parts[0]) + strlen(parts[1]) + 2
      let from = (start + end) / 2 - a:width / 2
    endif

    if from <= 0
      let from = 0
    elseif from + a:width > strlen(line)
      let from = strlen(line) - a:width
    end

    let line = strpart(line, from, a:width)
  endif

  return line
endfunction

""""""""""""""""""""
" Create the tabline
""""""""""""""""""""

function! TablineBuffersSetting()
    let [line, len] = s:TabString()
    return line . s:BufferString(&columns - len)
endfunction

"""""""""""""""""
" Global settings
"""""""""""""""""

augroup TablineBuffers
    au!
    au WinEnter * call s:TabWinEnter()
    auto BufAdd * call s:UpdateBufferList(-1)
    auto BufDelete * call s:UpdateBufferList(expand('<abuf>'))
augroup END

command! -nargs=1 TName call s:SetTabName(<args>)

set tabline=%!TablineBuffersSetting()
set showtabline=2

call s:CreateBufferList(-1)
