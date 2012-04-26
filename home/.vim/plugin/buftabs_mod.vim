"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" buftabs (C) 2006 Ico Doorn_ekamp
" Modified by sigh
"
" This program is free software; you can redistribute it and/or modify it
" under the terms of the GNU General Public License as published by the Free
" Software Foundation; either version 2 of the License, or (at your option)
" any later version.
"
" This program is distributed in the hope that it will be useful, but WITHOUT
" ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
" FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
" more details.
"
" Introduction
" ------------
"
" This is a simple script that shows a tabs-like list of buffers in the bottom
" of the window. The biggest advantage of this script over various others is
" that it does not take any lines away from your terminal, leaving more space
" for the document you're editing. The tabs are only visible when you need
" them - when you are switchin between buffers.
"
" Usage
" -----
"
" This script draws buffer tabs on vim startup, when a new buffer is created
" and when switching between buffers.
"
" It might be handy to create a few maps for easy switching of buffers in your
" .vimrc file. For example, using F1 and F2 keys:
"
"   noremap <f1> :bprev<CR>
"   noremap <f2> :bnext<CR>
"
" or using control-left and control-right keys:
"
"   :noremap <C-left> :bprev<CR>
"   :noremap <C-right> :bnext<CR>
"
"
" The following extra configuration variables are availabe:
"
" * g:buftabs_only_basename
"
"   Define this variable to make buftabs only print the filename of each buffer,
"   omitting the preceding directory name. Add to your .vimrc:
"
"   :let g:buftabs_only_basename=1
"
"
" * g:buftabs_in_statusline
"
"   Define this variable to make the plugin show the buftabs in the statusline
"   instead of the command line. It is a good idea to configure vim to show
"   the statusline as well when only one window is open. Add to your .vimrc:
"
"   set laststatus=2
"   :let g:buftabs_in_statusline=1
"
"   By default buftabs will take up the whole of the left-aligned section of
"   your statusline. You can alternatively specify precisely where it goes
"   using %{buftabs#statusline()} e.g.:
"
"   set statusline=%=buffers:\ %{buftabs#statusline()}
"
"
" * g:buftabs_active_highlight_group
" * g:buftabs_inactive_highlight_group
"
"   The name of a highlight group (:help highligh-groups) which is used to
"   show the name of the current_index active buffer and of all other inactive
"   buffers. If these variables are not defined, no highlighting is used.
"   (Highlighting is only functional when g:buftabs_in_statusline is enabled)
"
"   :let g:buftabs_active_highlight_group="Visual"
"
"
" * g:buftabs_marker_start    [
" * g:buftabs_marker_end      ]
" * g:buftabs_separator       -
" * g:buftabs_marker_modified !
"
"   These strings are drawn around each tab as separators, the 'marker_modified'
"   symbol is used to denote a modified (unsaved) buffer.
"
"   :let g:buftabs_separator = "."
"   :let g:buftabs_marker_start = "("
"   :let g:buftabs_marker_end = ")"
"   :let g:buftabs_marker_modified = "*"
"
"
" Changelog
" ---------
"
" 0.1  2006-09-22  Initial version
"
" 0.2  2006-09-22  Better handling when the list of buffers is longer then the
"                  window width.
"
" 0.3  2006-09-27  Some cleanups, set 'hidden' mode by default
"
" 0.4  2007-02-26  Don't draw buftabs until VimEnter event to avoid clutter at
"                  startup in some circumstances
"
" 0.5  2007-02-26  Added option for showing only filenames without directories
"                  in tabs
"
" 0.6  2007-03-04  'only_basename' changed to a global variable.  Removed
"                  functions and add event handlers instead.  'hidden' mode
"                  broke some things, so is disabled now. Fixed documentation
"
" 0.7  2007-03-07  Added configuration option to show tabs in statusline
"                  instead of cmdline
"
" 0.8  2007-04-02  Update buftabs when leaving insertmode
"
" 0.9  2007-08-22  Now compatible with older Vim versions < 7.0
"
" 0.10 2008-01-26  Added GPL license
"
" 0.11 2008-02-29  Added optional syntax highlighting to active buffer name
"
" 0.12 2009-03-18  Fixed support for split windows
"
" 0.13 2009-05-07  Store and reuse right-aligned part of original statusline
"
" 0.14 2010-01-28  Fixed bug that caused buftabs in command line being
"                  overwritten when 'hidden' mode is enabled.
"
" 0.15 2010-02-16  Fixed window width handling bug which caused strange
"                  behaviour in combination with the bufferlist plugin.
"                  Fixed wrong buffer display when deleting last window.
"                  Added extra options for tabs style and highlighting.
"
" 0.16 2010-02-28  Fixed bug causing errors when using buftabs in vim
"                  diff mode.
"
" 0.17 2011-03-11  Changed persistent echo function to restore 'updatetime',
"                  leading to better behaviour when showing buftabs in the
"                  status line. (Thanks Alex Bradbury)
"
" 0.18 2011-03-12  Added marker for denoting modified buffers, provide
"                  function for including buftabs into status line descriptor
"                  instead of buftabs having to edit the status line directly.
"                  (Thanks Andrew Ho)
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"
" Persistent echo to avoid overwriting of status line when 'hidden' is enabled
"

let s:Pecho=''
function! s:Pecho(msg)
  if &ut!=1|let s:hold_ut=&ut|let &ut=1|en
  let s:Pecho=a:msg
  aug Pecho
    au CursorHold * if s:Pecho!=''|echo s:Pecho
          \|let s:Pecho=''|let &ut=s:hold_ut|en
        \|aug Pecho|exe 'au!'|aug END|aug! Pecho
  aug END
endf

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

function! s:UpdateBufferList(deleted_buf)
  call s:CreateBufferList(a:deleted_buf)
  call s:Buftabs_show()
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

"
" Draw the buftabs
"

function! s:Buftabs_show()
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

  let width = &columns
  let string = join(items, ' ')
  if strlen(string) > width
    " If the resulting list is too long to fit on the screen, chop
    " out the appropriate part
    let from = 0
    " The trailing space is added so that there will always be three parts to
    " the split.
    let parts = split(string . ' ', '[()]')
    if len(parts) == 3
      let start = strlen(parts[0]) + 1
      let end = strlen(parts[0]) + strlen(parts[1]) + 2
      let from = (start + end) / 2 - width / 2
    endif

    if from <= 0
      let from = 0
    elseif from + width > strlen(string)
      let from = strlen(string) - width
    end

    let string = strpart(string, from, width)
  endif

  redraw
  call s:Pecho(string)
endfunction

"
" Hook to events to show buftabs at startup, when creating and when switching
" buffers
"

" WARNING: Do not call UpdateBufferList as this will call Buftabs_show and for
" some reason mess up the *shell* display outside of vim.
call s:CreateBufferList(-1)

autocmd BufAdd * call s:UpdateBufferList(-1)
autocmd BufDelete * call s:UpdateBufferList(expand('<abuf>'))
autocmd BufEnter,InsertLeave,VimResized * call s:Buftabs_show()

" vi: ts=2 sw=2

