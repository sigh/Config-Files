" Usage: :RE <register>
"   Will edit the register in a new buffer. If no register is given then
"   the unnamed register will be used
" To map use: map [mapping] :RE<CR>
"  When invoking the mapping if it is prefixed with "<reg> then that register
"  will be opened.

if exists('loaded_regedit')
  finish
endif
let loaded_regedit = 1

let s:writeable = '^[a-z@*+~/]$'
let s:readonly = '^[0-9:.%#=-]$'

command! -nargs=? -bang RE :call <SID>Start("<bang>", <f-args>)

function! s:Start(bang, ...)
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

  " Set upt the buffer if it doesn't exist
  if ! exists('b:regedit_regname')
    let b:regedit_regname = reg

    setlocal nobuflisted
    setlocal noswapfile
    setlocal buftype=
    setlocal noreadonly
    setlocal tabstop=8
    setlocal softtabstop=0
    setlocal shiftwidth=8
    setlocal noexpandtab
    setlocal autoindent
    setlocal formatoptions=tcqnl
    setlocal comments=:#,fb:-
    setlocal textwidth=80

    if readonly
        setlocal readonly
        autocmd BufWriteCmd <buffer> :echoerr 'Cannot write to this register'
    else
        autocmd BufWriteCmd <buffer> :call <SID>WriteRegister()
    endif

    autocmd BufReadCmd <buffer> :call <SID>ReadRegister()
    call s:ReadRegister()
  endif
endfunction

function! s:ReadRegister()
  let unnamed_reg = @@
  silent! exec 'normal ggVG"' . b:regedit_regname . 'p'
  let @@ = unnamed_reg
endfunction

function! s:WriteRegister()
    silent exec '1,$yank ' . b:regedit_regname
    setlocal nomodified
endfunction
