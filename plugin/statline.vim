" ============================================================================
" File:        statline.vim
" Maintainer:
" Description: Add useful info to the statusline and basic error checking.
" Last Change: 2013-09-11
" License:     This program is totaly free software.
" ============================================================================

if exists("g:loaded_statline_plugin")
    finish
endif
let g:loaded_statline_plugin = 1

" always display statusline (iss #3)
set laststatus=2

" ====== colors ======

" using link instead of named highlight group inside the statusline to make it
" easier to customize, reseting the User[n] highlight will remove the link.
" Another benefit is that colors will adapt to colorscheme.

"filename
hi default link User1 Identifier
" flags
hi default link User2 Statement
" errors
hi default link User3 Error
" fugitive
hi default link User4 Special

" ====== basic info ======

" ---- number of buffers : buffer number ----

function! StatlineBufCount()
    if !exists("s:statline_n_buffers")
        let s:statline_n_buffers = len(filter(range(1,bufnr('$')), 'buflisted(v:val)'))
    endif
    return s:statline_n_buffers
endfunction

if !exists('g:statline_show_n_buffers')
    let g:statline_show_n_buffers = 1
endif

if g:statline_show_n_buffers
    set statusline=[%{StatlineBufCount()}\:%n]%<
    " only calculate buffers after adding/removing buffers
    augroup statline_nbuf
        autocmd!
        autocmd BufAdd,BufDelete * unlet! s:statline_n_buffers
    augroup END
else
    set statusline=[%n]%<
endif

set statusline+=%1*[%f]

" (h:help:[help], w:window:[Preview], m:modified:[+][-], r:readonly:[RO])
set statusline+=%2*%h%w%m%r%*\ %y

" ---- file format → file encoding ----

let g:statline_encoding_separator = ':'
let g:statline_no_encoding_string = 'No Encoding'
set statusline+=[%{&ff}%{g:statline_encoding_separator}%{strlen(&fenc)?&fenc:g:statline_no_encoding_string}]

set statusline+=%=
set statusline+=%l:%c\ %P

" ====== plugins ======

" ---- Fugitive ----

if !exists('g:statline_fugitive')
    let g:statline_fugitive = 0
endif
if g:statline_fugitive
    set statusline+=%4*%{exists('g:loaded_fugitive')?fugitive#statusline():''}%*
endif

" ---- Syntastic errors ----

if !exists('g:statline_syntastic')
    let g:statline_syntastic = 1
endif
if g:statline_syntastic
    set statusline+=\ %3*%{exists('g:loaded_syntastic_plugin')?SyntasticStatuslineFlag():''}%*
endif

" --- trailing white space ---

if !exists('g:statline_trailing_space')
    let g:statline_trailing_space = 1
endif

function! StatlineTrailingSpaceWarning()
    if !exists("b:statline_trailing_space_warning")
        if search('\s\+$', 'nw') != 0
            let b:statline_trailing_space_warning = '[\s]'
        else
            let b:statline_trailing_space_warning = ''
        endif
    endif
    return b:statline_trailing_space_warning
endfunction

if g:statline_trailing_space
    set statusline+=%3*%{StatlineTrailingSpaceWarning()}%*

    " recalculate when idle, and after saving
    augroup statline_trail
        autocmd!
        autocmd cursorhold,bufwritepost * unlet! b:statline_trailing_space_warning
    augroup END
endif
