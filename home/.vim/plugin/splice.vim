" ============================================================================
" File:        splice.vim
" Description: vim global plugin for resolving three-way merge conflicts
" Maintainer:  Steve Losh <steve@stevelosh.com>
" License:     MIT X11
" ============================================================================

" Init {{{

if !exists('g:splice_debug') && (exists('g:splice_disable') || exists('loaded_splice') || &cp)
    finish
endif
let loaded_splice = 1

" }}}
" Commands {{{

command! -nargs=0 SpliceInit silent call splice#SpliceInit()

command! -nargs=0 SpliceGrid silent call splice#SpliceGrid()
command! -nargs=0 SpliceLoupe silent call splice#SpliceLoupe()
command! -nargs=0 SpliceCompare silent call splice#SpliceCompare()
command! -nargs=0 SplicePath silent call splice#SplicePath()

command! -nargs=0 SpliceOriginal silent call splice#SpliceOriginal()
command! -nargs=0 SpliceOne silent call splice#SpliceOne()
command! -nargs=0 SpliceTwo silent call splice#SpliceTwo()
command! -nargs=0 SpliceResult silent call splice#SpliceResult()

command! -nargs=0 SpliceDiff silent call splice#SpliceDiff()
command! -nargs=0 SpliceDiffoff silent call splice#SpliceDiffoff()
command! -nargs=0 SpliceScroll silent call splice#SpliceScroll()
command! -nargs=0 SpliceLayout silent call splice#SpliceLayout()
command! -nargs=0 SpliceNext silent call splice#SpliceNext()
command! -nargs=0 SplicePrev silent call splice#SplicePrev()
command! -nargs=0 SpliceUse silent call splice#SpliceUse()
command! -nargs=0 SpliceUse1 silent call splice#SpliceUse1()
command! -nargs=0 SpliceUse2 silent call splice#SpliceUse2()

" }}}
