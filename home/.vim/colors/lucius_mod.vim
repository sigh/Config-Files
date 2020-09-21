" Lucius vim color file
" Maintainer: Jonathan Filip <jfilip1024@gmail.com>
" Version: 7.1.1
" Modified by sigh

hi clear
if exists("syntax_on")
    syntax reset
endif
let colors_name="lucius_mod"

" Summary:
" Color scheme with dark and light versions (GUI and 256 color terminal).
"
" Description:
" This color scheme was originally created by combining my favorite parts of
" the following color schemes:
"
" * oceandeep (vimscript #368)
" * peaksea (vimscript #760)
" * wombat (vimscript #1778)
" * moria (vimscript #1464)
" * zenburn (vimscript #415)
"
" Version 7 has unified the 256 color terminal and GUI versions (the GUI
" version only uses colors available on the 256 color terminal). The overall
" colors were also toned down a little bit (light version is now a light gray
" instead of white and the dark version is slightly lighter) to make it easier
" on the eyes.
"
" Version 6+ has been revamped a bit from the original color scheme. If you
" prefer the old style, or the 'blue' version, use the 5Final release. Version
" 6+ only has a light and dark version. The new version tries to unify some of
" the colors and also adds more contrast between text and interface.
"
" The color scheme is dark, by default. You can change this by setting the
" g:lucius_style variable to "light", "dark", or "dark_dim". Once the color
" scheme is loaded, you can use the commands "LuciusLight", "LuciusDark", or
" "LuciusDarkDim" to change schemes quickly.
"
" Screenshots of version 7:
"
" * Dark: http://i.imgur.com/tgUsz.png
" * DarkDim: http://i.imgur.com/0bOCv.png
" * Light: http://i.imgur.com/ndd9A.png
"
" Screenshots of version 6:
"
" * Dark: http://i.imgur.com/IzYcB.png
" * Light: http://i.imgur.com/kfJcm.png
"
" Screenshots of the version 5Final:
"
" * Dark: http://i.imgur.com/z0bDr.png
" * Light: http://i.imgur.com/BXDiv.png
" * Blue: http://i.imgur.com/Ea1Gq.png
"
" colorsupport.vim (vimscript #2682) is used to help with mapping the GUI
" settings to the 256 terminal colors.
"
" This color scheme also has custom colors defined for the following plugins:
"
" * vimwiki (vimscript #2226)
" * tagbar (vimscript #3465)
"
" Installation:
" Copy the file to your vim colors directory and then do :colorscheme lucius.

set background=light

hi Normal       guifg=#444444   guibg=#eeeeee   ctermfg=0      ctermbg=15        gui=none      cterm=none

hi Comment      guifg=#808080   guibg=NONE      ctermfg=244    ctermbg=NONE      gui=none      cterm=none

hi Constant     guifg=#af5f00   guibg=NONE      ctermfg=130    ctermbg=NONE      gui=none      cterm=none
hi BConstant    guifg=#af5f00   guibg=NONE      ctermfg=130    ctermbg=NONE      gui=bold      cterm=bold

hi Identifier   guifg=#008700   guibg=NONE      ctermfg=28     ctermbg=NONE      gui=none      cterm=none
hi BIdentifier  guifg=#008700   guibg=NONE      ctermfg=28     ctermbg=NONE      gui=bold      cterm=bold

hi Statement    guifg=#005faf   guibg=NONE      ctermfg=25     ctermbg=NONE      gui=none      cterm=none
hi BStatement   guifg=#005faf   guibg=NONE      ctermfg=25     ctermbg=NONE      gui=bold      cterm=bold

hi PreProc      guifg=#008787   guibg=NONE      ctermfg=30     ctermbg=NONE      gui=none      cterm=none
hi BPreProc     guifg=#008787   guibg=NONE      ctermfg=30     ctermbg=NONE      gui=bold      cterm=bold

hi Type         guifg=#005f87   guibg=NONE      ctermfg=24     ctermbg=NONE      gui=none      cterm=none
hi BType        guifg=#005f87   guibg=NONE      ctermfg=24     ctermbg=NONE      gui=bold      cterm=bold

hi Special      guifg=#870087   guibg=NONE      ctermfg=90     ctermbg=NONE      gui=none      cterm=none
hi BSpecial     guifg=#870087   guibg=NONE      ctermfg=90     ctermbg=NONE      gui=bold      cterm=bold

" ## Text Markup ##
hi Underlined   guifg=fg        guibg=NONE      ctermfg=fg     ctermbg=NONE      gui=underline cterm=underline
hi Error        guifg=#af0000   guibg=#d7afaf   ctermfg=124    ctermbg=181       gui=none      cterm=none
hi Todo         guifg=#875f00   guibg=#ffffaf   ctermfg=94     ctermbg=229       gui=none      cterm=none
hi MatchParen   guifg=NONE      guibg=#5fd7d7   ctermfg=NONE   ctermbg=80        gui=none      cterm=none
hi NonText      guifg=#afafd7   guibg=NONE      ctermfg=146    ctermbg=NONE      gui=none      cterm=none
hi SpecialKey   guifg=#afd7af   guibg=NONE      ctermfg=151    ctermbg=NONE      gui=none      cterm=none
hi Title        guifg=#005faf   guibg=NONE      ctermfg=25     ctermbg=NONE      gui=bold      cterm=bold

" ## Text Selection ##
hi Cursor       guifg=bg        guibg=#5f87af   ctermfg=bg     ctermbg=67        gui=none      cterm=none
hi CursorIM     guifg=bg        guibg=#5f87af   ctermfg=bg     ctermbg=67        gui=none      cterm=none
hi CursorColumn guifg=NONE      guibg=#dadada   ctermfg=NONE   ctermbg=255       gui=none      cterm=none
hi CursorLine   guifg=NONE      guibg=#dadada   ctermfg=NONE   ctermbg=255       gui=none      cterm=none
hi Visual       guifg=NONE      guibg=#afd7ff   ctermfg=NONE   ctermbg=189       gui=none      cterm=none
hi VisualNOS    guifg=NONE      guibg=#afd7ff   ctermfg=NONE   ctermbg=189       gui=none      cterm=none
hi IncSearch    guifg=fg        guibg=#57d7d7   ctermfg=fg     ctermbg=202       gui=none      cterm=none
hi Search       guifg=fg        guibg=#ffaf00                  ctermbg=222       gui=none      cterm=none

" ## UI ##
hi Pmenu        guifg=bg        guibg=#808080   ctermfg=bg     ctermbg=244       gui=none      cterm=none
hi PmenuSel     guifg=fg        guibg=#afd7ff   ctermfg=fg     ctermbg=153       gui=none      cterm=none
hi PmenuSbar    guifg=#808080   guibg=#444444   ctermfg=244    ctermbg=238       gui=none      cterm=none
hi PmenuThumb   guifg=fg        guibg=#9e9e9e   ctermfg=fg     ctermbg=247       gui=none      cterm=none
hi StatusLine   guifg=bg        guibg=#808080   ctermfg=bg     ctermbg=237       gui=bold      cterm=bold
hi StatusLineNC guifg=#e4e4e4   guibg=#808080   ctermfg=0      ctermbg=244       gui=none      cterm=none
hi TabLine      guifg=bg        guibg=#808080   ctermfg=0      ctermbg=244       gui=none      cterm=none
hi TabLineFill  guifg=#b2b2b2   guibg=#808080   ctermfg=249    ctermbg=244       gui=none      cterm=none
hi TabLineSel   guifg=fg        guibg=#afd7ff   ctermfg=0      ctermbg=189       gui=none      cterm=none
hi VertSplit    guifg=#e4e4e4   guibg=#808080   ctermfg=254    ctermbg=244       gui=none      cterm=none
hi Folded       guifg=#626262   guibg=#bcbcbc   ctermfg=241    ctermbg=250       gui=bold      cterm=none
hi FoldColumn   guifg=#626262   guibg=#bcbcbc   ctermfg=241    ctermbg=250       gui=bold      cterm=none

" ## Spelling ##
hi SpellBad     guisp=#d70000                   ctermbg=210                      gui=undercurl cterm=underline
hi SpellCap     guisp=#00afd7                   ctermbg=153                      gui=undercurl cterm=underline
hi SpellRare    guisp=#5faf00                   ctermbg=114                      gui=undercurl cterm=underline
hi SpellLocal   guisp=#d7af00                   ctermbg=181                      gui=undercurl cterm=underline

" ## Diff ##
hi DiffAdd      guifg=fg        guibg=#afd7af                  ctermbg=151       gui=none      cterm=none
hi DiffChange   guifg=fg        guibg=#d7d7af                  ctermbg=153       gui=none      cterm=none
hi DiffDelete   guifg=fg        guibg=#d7afaf                  ctermbg=181       gui=none      cterm=none
hi DiffText     guifg=#d75f00   guibg=#d7d7af                  ctermbg=111       gui=bold      cterm=bold

" ## Misc ##
hi Directory    guifg=#00875f   guibg=NONE      ctermfg=29     ctermbg=NONE      gui=none      cterm=none
hi ErrorMsg     guifg=#af0000   guibg=NONE      ctermfg=124    ctermbg=NONE      gui=none      cterm=none
hi SignColumn   guifg=#626262   guibg=#d0d0d0   ctermfg=241    ctermbg=252       gui=none      cterm=none
hi LineNr       guifg=#9e9e9e   guibg=#dadada   ctermfg=247    ctermbg=255       gui=none      cterm=none
hi CursorLineNr guifg=#9e9e9e   guibg=#dadada   ctermfg=247    ctermbg=255       gui=none      cterm=none
hi MoreMsg      guifg=#005fd7   guibg=NONE      ctermfg=26     ctermbg=NONE      gui=none      cterm=none
hi ModeMsg      guifg=fg        guibg=NONE      ctermfg=fg     ctermbg=NONE      gui=none      cterm=none
hi Question     guifg=fg        guibg=NONE      ctermfg=fg     ctermbg=NONE      gui=none      cterm=none
hi WarningMsg   guifg=#af5700   guibg=NONE      ctermfg=130    ctermbg=NONE      gui=none      cterm=none
hi WildMenu     guifg=fg        guibg=#afd7ff   ctermfg=fg     ctermbg=153       gui=none      cterm=none
hi ColorColumn  guifg=NONE      guibg=#d7d7af   ctermfg=NONE   ctermbg=187       gui=none      cterm=none
hi Ignore       guifg=bg                        ctermfg=bg
