" From: http://www.perlmonks.org/?node_id=90172

" Vim filetype plugin file
" Language: Perl
" Maintainer: Ned Konz <ned@bike-nomad.com>
" Last change: $Date: 2001/06/20 20:23:37 $
" $Revision: 1.6 $

" Set this once, globally.
if !exists("perlpath")
  let perlpath = system('perl -e "print join(\",\",@INC)"')
endif

" Set 'formatoptions' to break comment lines but not other lines,
" and insert the comment leader when hitting <CR> or using "o".
setlocal fo-=t fo+=croql
setlocal include=\\<\\(use\\\|require\\)\\>
setlocal includeexpr=substitute(substitute(v:fname,'::','/','g'),'$','
+.pm','')
setlocal isfname=A-Z,a-z,:,48-57,_
setlocal keywordprg=perldoc
setlocal iskeyword=48-57,_,A-Z,a-z,: 
setlocal isident=48-57,_,A-Z,a-z
setlocal define=^\\s*sub
setlocal comments=:#
let &l:path=perlpath
setlocal makeprg=perl\ -Mstrict\ -wc\ %
setlocal errorformat+=%m\ at\ %f\ line\ %l.
" setlocal grepprg=grep\ -n\ -R\ '*.p[ml]'\ $*

" set equalprg to use perltidy if available
if executable("perltidy")
    equalprg=perltidy
endif
