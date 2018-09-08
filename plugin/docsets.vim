"=============================================================================
" FILE: docsets.vim
" AUTHOR: DaSea
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================
if exists('g:loaded_docsets_vim')
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

let g:loaded_docsets_vim= 1

augroup exprj
    autocmd!
    autocmd VimLeavePre * call s:exit()
augroup END

" Variables{{{
if !exists('g:docsets_path_root')
    let g:docsets_path_root = ""
endif

if !exists('g:docsets_filetype_map')
    let g:docsets_filetype_map = {"cpp":"C++.docset", "c":"C.docset",
                \ "python":"Python_3.docset", "bash":"Bash.docset",
                \ "go":"Go.docset"}
endif
"}}}

" commands{{{
" This command need two param, search type and search content.
command! -nargs=+ DocsetsSearch call docsets#search(<f-args>)
" Write extension for LeaderF
" command! -bar -nargs=0 LeaderfDocsets call leaderf#docset#startExpl(g:Lf_WindowPosition)
command! -bar -nargs=? -complete=filetype LeaderfDocsets call leaderf#docset#startExpl(g:Lf_WindowPosition, <f-args>)
"}}}

" Initial {{{
call docsets#init()
call g:LfRegisterSelf("LeaderfDocsets", "navigate the docsets")
" }}}

" Private function {{{
function! s:exit() abort " exit {{{
    call docsets#exit()
endfunction " }}}
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker

