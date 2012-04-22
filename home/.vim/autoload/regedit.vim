" Define a command:
"   command! -nargs=? -bang RE :call regedit#Start("<bang>", <f-args>)
" Usage: :RE <register>
"   Will edit the register in a new buffer. If no register is given then
"   the unnamed register will be used
" To map use: map [mapping] :RE<CR>
"  When invoking the mapping if it is prefixed with "<reg> then that register
"  will be opened.

" if exists('g:loaded_regedit_autoload')
  " finish
" endif
" let g:loaded_regedit_autoload = 1

let s:writeable = '^[a-z@*+~/]$'
let s:readonly = '^[0-9:.%#=-]$'

function! regedit#Start(bang, ...)
  " Find which register the user wants
  let reg = '@' " Unnammed register is the default
  if a:0 > 0
    let reg = tolower(a:1)
  elseif v:register != '' && v:register != '"'
    let reg = tolower(v:register)
  endif

  " Check that the register is valid
  if reg =~ s:writeable
    let readonly = 0
  elseif reg =~ s:readonly
    let readonly = 1
  else
    echoerr 'Unknown register: ' . reg
    return
  endif

  " Create (or switch to) the buffer
  let _isf = &isfname
  try
    set isfname=1-255 " Anything goes in a filename
    exec 'e' . a:bang . ' [Register ' . reg . ']'
  finally
    let &isfname = _isf
  endtry

  " Determine the type
  call s:SetRegType(getregtype(reg))

  " Set upt the buffer if it doesn't exist
  if ! exists('b:regedit_regname')
    let b:regedit_regname = reg

    if readonly
        setlocal readonly
        autocmd BufWriteCmd <buffer> :echoerr 'Cannot write to this register'
    else
        autocmd BufWriteCmd <buffer> :call <SID>WriteRegister()
    endif

    autocmd BufReadPre <buffer> :call <SID>SetupBuffer()
    autocmd BufReadCmd <buffer> :call <SID>ReadRegister()
  endif

  call s:SetupBuffer()
  call s:ReadRegister()
endfunction

function! s:SetupBuffer()
  setlocal nobuflisted
  setlocal noswapfile
  setlocal buftype=acwrite
  setlocal tabstop=8
  setlocal softtabstop=0
  setlocal shiftwidth=8
  setlocal noexpandtab
  setlocal formatoptions=l
  setlocal textwidth=0
endfunction

function! s:ReadRegister()
  let unnamed_reg = @@
  silent! exec 'normal ggVG"' . b:regedit_regname . 'p'
  setlocal nomodified
  let @@ = unnamed_reg
endfunction

function! s:WriteRegister()
  let unnamed_reg = @@

  silent normal ggyG
  if b:regedit_regtype ==# 'v'
    " Don't want newline at the end in character mode
    let @@ = substitute(@@, '\n$', '', '')
  endif
  call setreg(b:regedit_regname, @@, b:regedit_regtype)
  setlocal nomodified

  if b:regedit_regname != '@'
    let @@ = unnamed_reg
  endif
endfunction

function! s:SetRegType(type)
  if a:type =~ ''
    let b:regedit_regtype = 'b'
    let &ft = 'block'
  elseif a:type ==# 'v'
    let b:regedit_regtype = 'v'
    let &ft = 'character'
  else
    let b:regedit_regtype = 'V'
    let &ft = 'line'
  endif
endfunction
