" Quickfix window settings

if !exists("b:quickfix_settings_loaded")
  map <buffer> <Tab> <Enter><Leader>qq
  map <buffer> <S-Tab> <Nop>
  noremap <buffer> <CR> <CR>

  setlocal nobuflisted
  setlocal nocursorline

  " Folding
  setlocal foldlevel=0
  setlocal foldmethod=expr
  setlocal foldexpr=matchstr(getline(v:lnum),'^[^\|]\\+')==#matchstr(getline(v:lnum+1),'^[^\|]\\+')?1:'<1'

  let b:quickfix_settings_loaded=1
endif
