"
" z.vim
"
" Last Change:  Tue Mai  28 03:40:28 EDT 2013
" Maintainer:   Henrik Kjelsberg <hkjels@me.com> (http://take.no/)
" License:      MIT
"

if exists("g:loaded_z")
  finish
endif
let g:loaded_z = 1


" `z`-native preferences

if exists("g:z_data")
  let $_Z_DATA = resolve(expand(g:z_data))
endif
if exists("g:z_no_resolve_symlinks")
  let $_Z_NO_RESOLVE_SYMLINKS = g:z_no_resolve_symlinks
endif
if exists("g:z_exclude_dirs")
  let $_Z_EXCLUDE_DIRS = g:z_exclude_dirs
endif


" Override native `cd`-command, so that the `z` index is updated
" with whatever directories you `cd` into.
" TODO Directories should be indexed upon `cd`
"    | ATM #z will ouput an error with the "fun" below.

" fun! s:CD(directory)
"   exec '!cd '.directory
"   exec 'cd '.directory
" endfun
" 
" cabbrev cd <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'CD' : 'cd')<CR>


" Takes a list of regular expressions and returns a list
" of paths and weights.

fun! s:list(list)
  let regexes = shellescape(join(a:list))
  let list = split(system('_z -l '.regexes), '\n')
  return list
endfun


" Takes a string "weight directory" and returns a
" resolved path.

fun! s:pickDir(line)
  let directory = resolve(expand(join(split(a:line)[1:], '\\ ')))
  return directory
endfun


" Create an interactive non-modifiable buffer with the list of
" directories that match the regexes passed if any.

fun! s:InteractiveList(...)
  " Set up window and buffer
  10new
  set buftype=nofile bufhidden=hide
  setlocal noswapfile
  call append(0, s:list(a:000))

  " No matches
  if (line2byte(line('$') + 1) == -1)
    echo '`z` found no matches for your query'
    return
  endif

  %s@\n\n@@g
  setlocal nomodifiable
  0

  " Syntax highlighting
  syn match Zratio "^[0-9\.]*"
  syn match Zdirectory "[\.A-Za-z-]*$"
  hi def link Zratio Number
  hi def link Zdirectory Special

  " Keystrokes for opening the highlighted directory in a new window
  " or simply `cd` into it.
  " NOTE: These mappings might not be final. I'll have to check out some
  "       best practises. Also the mapping itself is pretty ugly.

  noremap <buffer> <silent> <enter> :exec ':let ZDIR=<SID>pickDir("'.getline(".").'")'<cr>:exec 'cd '.ZDIR<cr>:q<cr>
  noremap <buffer> <silent> <LeftRelease> :exec ':let ZDIR=<SID>pickDir("'.getline(".").'")'<cr>:q<cr>:exec ':new '.ZDIR<cr>
  noremap <buffer> <silent> <c-o> :exec ':let ZDIR=<SID>pickDir("'.getline(".").'")'<cr>:q<cr>:exec ':new '.ZDIR<cr>
  noremap <buffer> <silent> <c-s> :exec ':let ZDIR=<SID>pickDir("'.getline(".").'")'<cr>:q<cr>:exec ':vs '.ZDIR<cr>
endfun


" Set most frecent directory as CWD

fun! s:QuickJump(...)
  try
    let info = s:list(a:000)[0]
  catch
    echo '`z` found no matches for your query'
    return
  endtry
  let directory = s:pickDir(info)
  exec 'cd '.directory
endfun


" Interface exposed to the user

command! -nargs=* Zl call s:InteractiveList(<f-args>)
command! -nargs=* Z call s:QuickJump(<f-args>)

