" Vim color file
" Maintainer: David Ne\v{c}as (Yeti) <yeti@physics.muni.cz>
" Last Change: 2003-04-23
" URL: http://trific.ath.cx/Ftp/vim/colors/peachpuff.vim

" This color scheme uses a peachpuff background (what you've expected when it's
" called peachpuff?).
"
" Note: Only GUI colors differ from default, on terminal it's just `light'.
"
" Modified by sigh

" First remove all existing highlighting.
set background=light
hi clear
if exists("syntax_on")
  syntax reset
endif

let colors_name = "peachpuff"

hi Normal guibg=PeachPuff guifg=Black

hi SpecialKey term=bold ctermfg=4 guifg=Blue
hi NonText term=bold cterm=bold ctermfg=4 gui=bold guifg=Blue
hi Directory term=bold ctermfg=4 guifg=Blue
hi ErrorMsg term=standout cterm=NONE ctermfg=7 ctermbg=1 gui=bold guifg=White guibg=Red
hi IncSearch term=reverse cterm=NONE ctermbg=4 ctermfg=7  gui=reverse
hi Search term=reverse ctermbg=6 ctermfg=0 guibg=Gold2
hi MoreMsg term=bold ctermfg=2 gui=bold guifg=SeaGreen
hi ModeMsg term=bold cterm=NONE ctermfg=1 gui=bold
hi LineNr term=underline ctermfg=7 ctermbg=NONE cterm=NONE guifg=Red3
hi Question term=standout ctermfg=2 gui=bold guifg=SeaGreen
hi StatusLine term=bold,reverse cterm=NONE ctermfg=7 ctermbg=4 gui=bold guifg=White guibg=Black
hi StatusLineNC term=reverse cterm=underline ctermfg=4 ctermbg=7 gui=bold guifg=PeachPuff guibg=Gray45
hi VertSplit term=reverse cterm=NONE ctermbg=7 gui=bold guifg=White guibg=Gray45
hi Title term=bold ctermfg=5 gui=bold guifg=DeepPink3
hi Visual term=reverse cterm=NONE ctermfg=0 ctermbg=7 gui=reverse guifg=Grey80 guibg=fg
hi VisualNOS term=bold,underline cterm=underline gui=bold,underline
hi WarningMsg term=standout ctermfg=1 gui=bold guifg=Red
hi WildMenu term=standout ctermfg=0 ctermbg=3 guifg=Black guibg=Yellow
hi Folded term=standout ctermfg=4 ctermbg=7 guifg=Black guibg=#e3c1a5
hi FoldColumn term=standout ctermfg=4 ctermbg=7 guifg=DarkBlue guibg=Gray80
hi DiffAdd term=bold ctermbg=5 ctermfg=0 guibg=White
hi DiffDelete term=bold cterm=NONE ctermfg=0 ctermbg=7 gui=bold guifg=LightBlue guibg=#f6e8d0
hi DiffChange term=bold cterm=NONE ctermbg=3 ctermfg=0 guibg=#edb5cd
hi DiffText term=reverse cterm=NONE ctermbg=2 ctermfg=0 gui=bold guibg=#ff8060
hi Cursor guifg=bg guibg=fg
hi lCursor guifg=bg guibg=fg
hi MatchParen ctermbg=yellow
hi ColorColumn ctermbg=blue ctermfg=white

" Colors for syntax highlighting
hi Comment term=bold ctermfg=4 guifg=#406090
hi Constant term=underline ctermfg=1 guifg=#c00058
hi Special term=bold ctermfg=5 guifg=SlateBlue
hi Identifier term=underline ctermfg=6 guifg=DarkCyan
hi Statement term=bold ctermfg=3 gui=bold guifg=Brown
hi PreProc term=underline ctermfg=5 guifg=Magenta3
hi Type term=underline ctermfg=2 gui=bold guifg=SeaGreen
hi Ignore cterm=NONE ctermfg=7 guifg=bg
hi Error term=reverse cterm=NONE ctermfg=7 ctermbg=1 gui=bold guifg=White guibg=Red
hi Todo term=standout ctermfg=4 ctermbg=7 guifg=Blue guibg=Yellow

" overrides for when we have at least 16 colours
if &t_Co >= 16
    hi LineNr ctermfg=8
    hi DiffAdd ctermbg=13 ctermfg=0 
    hi DiffDelete ctermfg=0 ctermbg=8  
    hi DiffChange ctermbg=3 ctermfg=0 
    hi DiffText ctermbg=11 ctermfg=0 
    hi IncSearch ctermfg=15
    hi Search ctermfg=15
    hi Error ctermfg=15
endif
