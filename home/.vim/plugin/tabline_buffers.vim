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

"""""""""""""""""""
" Buffer list setup
"""""""""""""""""""

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

""""""""""""""""""""""
" Create buffer string
""""""""""""""""""""""

function! s:BufferString(width)
  let [items, current_index] = s:BufferItems()

  call s:TrimBufferItems(items, current_index, a:width)

  let line = ''
  for [caption, hl] in items
      let line .= caption . ' '
  endfor

  return line
endfunction

function! s:TrimBufferItems(items, center, width)
    " Length of the item we want centered
    let len_center = strlen(a:items[a:center][0])

    " Length of the items before the center
    let len_prefix = 0
    if a:center > 0
        let len_prefix = s:BufferItemsStrlen(a:items[: a:center - 1]) + 1
    endif

    " Length of the items from the center onwards
    let len_suffix = s:BufferItemsStrlen(a:items[a:center :])

    " The required length of the each of the sides
    let wanted_len_prefix = max([(a:width - len_center) / 2, 0])
    let wanted_len_suffix = a:width - wanted_len_prefix

    " If either prefix or suffix have too much space then give it to the other
    " side
    if len_prefix < wanted_len_prefix
        let wanted_len_suffix += wanted_len_prefix - len_prefix
        let wanted_len_prefix = len_prefix
    endif
    if len_suffix < wanted_len_suffix
        let wanted_len_prefix += wanted_len_suffix - len_suffix
        let wanted_len_prefix = min([wanted_len_prefix, len_prefix])
        let wanted_len_suffix = len_suffix
    endif

    " Trim the suffix
    for i in range(a:center, len(a:items)-1)
        let item = a:items[i]
        let len = strlen(item[0])
        if wanted_len_suffix <= 0
            " We don't want the rest of the items
            call remove(a:items, i, -1)
            break
        elseif wanted_len_suffix < len
            " Trim some of this item
            let item[0] = item[0][: wanted_len_suffix - len - 1]
            let wanted_len_suffix = 0
        else
            " Trim none of this item
            let wanted_len_suffix -= len + 1
        endif
    endfor

    " Trim the prefix
    let wanted_len_prefix -= 1 " Trim the last space for free!
    for i in range(a:center-1, 0, -1)
        let item = a:items[i]
        let len = strlen(item[0])
        if wanted_len_prefix <= 0
            " We don't want the rest of the items
            call remove(a:items, 0, i)
            break
        elseif wanted_len_prefix < len
            " Trim some of this item
            let item[0] = item[0][len - wanted_len_prefix :]
            let wanted_len_prefix = 0
        else
            " Trim none of this item
            let wanted_len_prefix -= len + 1
        endif
    endfor
endfunction

function! s:BufferItemsStrlen(items)
    if len(a:items) == 0
        return 0
    endif

    let len = 0

    for item in a:items
        let len += strlen(item[0])
    endfor

    " Add one space between each item
    return len + len(a:items) - 1
endfunction

function! s:BufferItems()
  let current_buffer = bufnr('%')

  let i = 0
  let items = []
  let current_index = -1
  for item in s:buffers
    let i = i + 1
    if item == ''
      continue
    endif

    let hl = ''
    if i == current_buffer
      let hl = 'Selected'
      let current_index = len(items)
    elseif bufwinnr(i) != -1
      let hl = 'Visible'
    endif

    call add(items, [i . ':' . item, hl])
  endfor

  return [items, current_index]
endfunction

""""""""""""""""""""
" Create the tabline
""""""""""""""""""""

function! TablineBuffersSetting()
    let [line, len] = s:TabString()
    " If we don't remove 1 from the width then the tabline truncates 1 character
    " in the line even though there is enough space :(
    return line . s:BufferString(&columns - len - 1)
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
