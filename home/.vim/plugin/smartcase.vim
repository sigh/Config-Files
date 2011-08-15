" Script Name: smartcase.vim
" Version:     1.0.2
" Last Change: January 12, 2006
" Author:      Yuheng Xie <elephant@linux.net.cn>
"
" Description: replacing words while keeping original lower/uppercase style
"
"              An example, you may want to replace any FileSize appears in
"              your program into LastModifiedTime. Since it appears everywhere
"              as both uppercases and lowercases, you have to write it several
"              times:
"
"                :%s/FileSize/LastModifiedTime/g      " function names
"                :%s/file_size/last_modified_time/g   " variable names
"                :%s/FILE_SIZE/LAST_MODIFIED_TIME/g   " macros
"                :%s/File size/Last modified time/g   " document/comments
"                ......
"
"              This script copes with the case style for you so that you need
"              write just one command:
"
"                :%s/file\A\?size/\=SC("LastModifiedTime")/ig
"
" Details:     SC(str_words, str_styles = 0) make a new string using
"              the words from str_words and the lower/uppercases styles from
"              str_styles. If any of the arguments is a number n, it's
"              equivalent to submatch(n). If str_styles is omitted, it's 0.
"
"              SC recognizes words in three case styles: 1: xxxx (all
"              lowercases), 2: XXXX(all uppercases) and 3: Xxxx(one uppercase
"              following by lowercases).
"
"              For example, str_styles "getFileName" will be cut into three
"              words: "get"(style 1), "File"(style 3) and "Name"(style 3). If
"              str_words is "MAX_SIZE", it will be treated as two words: "max"
"              and "size", their case styles is unimportant. The final result
"              string will be "maxSize".
"
"              A note, in the case some uppercases following by some
"              lowercases, e.g. "HTMLFormat", SC will treat it as
"              "HTML"(2) and "Format"(3) instead of "HTMLF"(2) and "ormat"(1).
"
" Usage:       1. call SC(str_words, str_styles) in replace expression
"
"              The simplest way: (in most cases, you will need the /i flag)
"
"                :%s/goodday/\=SC("HelloWorld")/ig
"
"              This will replace any GoodDay into HelloWorld, GOODDAY into
"              HELLOWORLD, etc.
"
"              For convenience, if str_styles is omitted, it will be set to
"              submatch(0). Or if any of the arguments is a number n, it will
"              be set to submatch(n). Example:
"
"                :%s/good\(day\)/\=SC("HelloWorld", 1)/ig
"
"              It's equivalent to:
"
"                :%s/good\(day\)/\=SC("HelloWorld", submatch(1))/ig
"
"              2. use SC as command
"
"              First search for a string: (\c for ignoring case)
"
"                /\cgoodday
"
"              Then use command: (note that a range is needed, and it doesn't
"              matter whether you say "hello world" or "HelloWorld" as long as
"              words could be discerned.)
"
"                :%SC "hello world"
"
"              This will do exactly the same as mentioned in usage 1.
"
"              3. replacing lower/uppercases style, keeping original words
"
"              As an opposition to usage 1., this can be achieved by using
"              submatch(0) as str_words instead of str_styles. Example:
"
"                :%s/\(\u\l\+\)\+/\=SC(0, "x_x")/g
"
"              This will replace any GoodDay into good_day, HelloWorld into
"              hello_world, etc.

command! -rang -nargs=+ SC :<line1>,<line2>s//\=SC(<args>)/g

" make a new string using the words from str_words and the lower/uppercase
" styles from str_styles
function! SC(...) " SC(str_words, str_styles = 0)
	if a:0 == 0
		return
	elseif a:0 == 1
		let str_words = a:1
		let str_styles = submatch(0)
		if matchstr(str_words, '\d\+') == str_words
			let str_words = submatch(0 + str_words)
		endif
	else
		let str_words = a:1
		let str_styles = a:2
		if matchstr(str_words, '\d\+') == str_words
			let str_words = submatch(0 + str_words)
		endif
		if matchstr(str_styles, '\d\+') == str_styles
			let str_styles = submatch(0 + str_styles)
		endif
	endif

	let regexp = '\l\+\|\u\l\+\|\u\+\l\@!'
	let result = ""
	let i = 0
	let j = 0
	let separator = ""
	let case = 0
	while j < strlen(str_words)
		if i < strlen(str_styles)
			let s = match(str_styles, regexp, i)
			if s >= 0
				let e = matchend(str_styles, regexp, s)
				let separator = strpart(str_styles, i, s - i)
				let word = strpart(str_styles, s, e - s)
				if word ==# tolower(word)
					let case = 1  " all lowercases
				elseif word ==# toupper(word)
					let case = 2  " all uppercases
				else
					let case = 3  " one uppercase following by lowercases
				endif
				let i = e
			endif
		endif

		let s = match(str_words, regexp, j)
		if s >= 0
			let e = matchend(str_words, regexp, s)
			let word = strpart(str_words, s, e - s)
			if case == 1
				let result = result . separator . tolower(word)
			elseif case == 2
				let result = result . separator . toupper(word)
			elseif case == 3
				let result = result . separator . toupper(strpart(word, 0, 1)) . tolower(strpart(word, 1))
			else
				let result = result . separator . word
			endif
			let j = e
		else
			break
		endif
	endwhile

	while i < strlen(str_styles)
		let e = matchend(str_styles, regexp, i)
		if e >= 0
			let i = e
		else
			break
		endif
	endwhile
	let result = result . strpart(str_styles, i)

	return result
endfunction
