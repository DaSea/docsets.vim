if exists('g:docsets#loaded')
    finish
else
    let g:docsets#loaded = 1
endif

if !exists("g:Curr_PythonVersion")
    if has("python3")
        let g:Curr_PythonVersion = 3
        let g:CurrPy = "py3 "
    elseif has("python")
        let g:Curr_PythonVersion = 2
        let g:CurrPy = "py "
    else
        echohl Error
        echo "Error: docsets.vim requires vim compiled with +python or +python3"
        echohl None
        finish
    endif
else
    if g:Curr_PythonVersion == 2
        if has("python")
            let g:CurrPy = "py "
        else
            echohl Error
            echo 'docsets.vim Error: has("python") == 0'
            echohl None
            finish
        endif
    else
        if has("python3")
            let g:CurrPy = "py3 "
        else
            echohl Error
            echo 'docsets.vim Error: has("python3") == 0'
            echohl None
            finish
        endif
    endif
endif

" Variables{{{
let s:is_windows = has('win16') || has('win32') || has('win64') || has('win95')

let s:win_title = 'DocsetsWin'

" winpos(aboveleft, belowright)
if !exists('g:docsets_win_pos')
    let g:docsets_win_pos = 'vertical'
endif
"}}}

function! s:substitute_path_separator(path) "{{{
  return s:is_windows ? substitute(a:path, '\\', '/', 'g') : a:path
endfunction "}}}


" let s:docsets_py_path = fnamemodify(expand('<sfile>'), ':p:h')
exec g:CurrPy "import vim, sys, os, os.path"
exec g:CurrPy "cwd = vim.eval('expand(\"<sfile>:p:h\")')"
exec g:CurrPy "sys.path.insert(0, cwd)"

function! docsets#init() abort " Set initial value to python script {{{
    " import and make a objects
exec g:CurrPy "from docsetmgr import docsetManager"
    exec g:CurrPy "docroot = vim.eval('g:docsets_path_root')"
    exec g:CurrPy "docmap = vim.eval('g:docsets_filetype_map')"
    exec g:CurrPy "docsetManager.setAttr(docroot, docmap)"
endfunction " }}}

""""""""""""""""""""""""
" type: c, cpp, python and so on
" content: function-malloc and so on
"""""""""""""""""""
function! docsets#search(type, content) abort "{{{
    " echomsg a:type
    " echomsg a:content

    if strlen(g:docsets_path_root)==0:
        return
    endif

    call docsets#open_window()
    call docsets#init_docsets_windows(a:type, a:content)
endfunction "}}}

" need create window
function! docsets#toggle_window() abort "{{{
    let winnr = bufwinnr(s:win_title)
    if -1 != winnr
        call docsets#close_window()
        return
    else
        " if window is not exists, open it
        call docsets#open_window()
    endif

    " clear display content
    normal! ggdG
endfunction "}}}

function! docsets#close_window() abort "{{{
    let winnr = bufwinnr(s:win_title)
    if -1 != winnr
        " jump to the window
        exe winnr . 'wincmd w'
        " if this is not the only window, close it
        try
            close
        catch /E444:/
            echo 'Can not close the last window!'
        endtry

        doautocmd BufEnter
        return 1
    endif

    return 0
endfunction "}}}

function! docsets#open_window() abort "{{{
    " if the buffer already exists, reuse it
    " Otherwise create a new buffer
    let winnr = bufwinnr(s:win_title)
    if winnr == -1
        " Make sure winpos and winsize
        let winpos = g:docsets_win_pos

        let bufnum = bufnr(s:win_title)
        let bufcmd = ''
        if -1 == bufnum
            let bufcmd = fnameescape(s:win_title)
        else
            let bufcmd = '+b' . bufnum
        endif

        " create window
        silent exe winpos . ' split ' . bufcmd

        silent! setlocal winfixheight
        silent! setlocal winfixwidth
        silent! setlocal buftype=nofile
        " silent! setlocal bufhidden=hide
        silent! setlocal noswapfile
        silent! setlocal nobuflisted
        silent! setlocal number
        set filetype=markdown
    else
        exe winnr . 'wincmd w'
        " clear buffer, and don't put them to clipboard
        normal! "_ggdG
    endif
endfunction "}}}

function! docsets#init_docsets_windows(type, content) abort "{{{
    " set project list context to windows
    if line('$') <= 1
        call docsets#fill_docsets_cache(a:type, a:content)
    endif

    " Delete the last empty line
    normal! G
    let curline = getline('.')
    if strlen(curline) == 0
        normal! dd
    endif
    normal! gg
endfunction "}}}

function! docsets#fill_docsets_cache(type, content) abort " fill result {{{
    exec g:CurrPy "from docsetmgr import docsetManager"
    exec g:CurrPy "searchtype = vim.eval('a:type')"
    exec g:CurrPy "searchcontent = vim.eval('a:content')"
    exec g:CurrPy "docsetManager.search(searchtype, searchcontent)"
endfunction " }}}

function! docsets#exit() abort "{{{
    " echo 'exit'
endfunction "}}}

