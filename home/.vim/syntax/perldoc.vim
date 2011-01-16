syntax include @Perl syntax/perl.vim
syntax include @Man syntax/man.vim

syntax region perlSnip start="^        " end="$" contains=@Perl
syntax region manSnip  start="^" end="$" contains=@Man oneline
