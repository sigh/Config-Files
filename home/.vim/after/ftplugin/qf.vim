" Quickfix window settings

if !exists("b:quickfix_settings_loaded")
  map <buffer> <Tab> <Enter><Leader>qq
  map <buffer> <S-Tab> <Nop>

  setlocal nobuflisted
  setlocal nocursorline

  " Folding
  setlocal foldexpr=matchstr(getline(v:lnum),'^[^\|]\\+')==#matchstr(getline(v:lnum+1),'^[^\|]\\+')?1:'<1'
  setlocal foldlevel=0

  let b:quickfix_settings_loaded=1
endif

" For some reason async doesn't work if this is inside the if.
setlocal foldmethod=expr
