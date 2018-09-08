" ============================================================================
" File:        Marks.vim
" Description:
" Author:      Yggdroot <archofortune@gmail.com>
" Website:     https://github.com/Yggdroot
" Note:
" License:     Apache License, Version 2.0
" ============================================================================

if leaderf#versionCheck() == 0
    finish
endif

exec g:Lf_py "import vim, sys, os.path"
exec g:Lf_py "cwd = vim.eval('expand(\"<sfile>:p:h\")')"
exec g:Lf_py "sys.path.insert(0, os.path.join(cwd, 'python'))"
exec g:Lf_py "from docsetsExpl import *"

function! leaderf#docset#Maps()
    nmapclear <buffer>
    nnoremap <buffer> <silent> <CR>          :exec g:Lf_py "docsetsExplManager.accept()"<CR>
    nnoremap <buffer> <silent> q             :exec g:Lf_py "docsetsExplManager.quit()"<CR>
    nnoremap <buffer> <silent> i             :exec g:Lf_py "docsetsExplManager.input()"<CR>
    nnoremap <buffer> <silent> <F1>          :exec g:Lf_py "docsetsExplManager.toggleHelp()"<CR>
endfunction

function! leaderf#docset#startExpl(win_pos, ...)
    " call leaderf#LfPy("docsetsExplManager.startExplorer('".a:win_pos."')")
    if a:0 == 0
        let ftype = &filetype
        " call leaderf#LfPy("docsetsExplManager.startExplorer('".a:win_pos."')")
    else
        let ftype = a:1
    endif
    call leaderf#LfPy("docsetsExplManager.startExplorer('".a:win_pos."', arguments={'filetype': ['".ftype."']})")
endfunction
