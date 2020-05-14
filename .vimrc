set nocompatible              " be iMproved, required
filetype off                  " required

" Set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'tpope/vim-sensible'
Plugin 'flazz/vim-colorschemes'
Plugin 'txt.vim'
"Plugin 'Syntastic'
Plugin 'scrooloose/nerdtree'
Plugin 'b4winckler/vim-angry'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'tpope/vim-commentary'
Plugin 'nvie/vim-flake8'
Plugin 'othree/html5.vim'
Plugin 'godlygeek/tabular'
Plugin 'fatih/vim-go'
"Plugin 'chrisbra/Recover.vim'
"Plugin 'gioele/vim-autoswap'
Plugin 'sk1418/Join'
Plugin 'tpope/vim-surround'
Plugin 'robhurring/todo.vim'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" Plugin Config
let g:go_version_warning = 0

"" todo.vim
autocmd FileType markdown nmap <buffer> <localleader>i <Plug>(todo-new)
autocmd FileType markdown nmap <buffer> <localleader>I <Plug>(todo-new-below)
autocmd FileType markdown imap <buffer> <localleader>i <Plug>(todo-new)
autocmd FileType markdown imap <buffer> <localleader>I <Plug>(todo-new-below)

autocmd FileType markdown nmap <buffer> <localleader>x <Plug>(todo-mark-as-done)
autocmd FileType markdown nmap <buffer> <localleader>X <Plug>(todo-mark-as-undone)
autocmd FileType markdown vmap <buffer> <localleader>x <Plug>(todo-mark-as-done)
autocmd FileType markdown vmap <buffer> <localleader>X <Plug>(todo-mark-as-undone)

" Aliases/Helpers
:command! Reload so %

" ###### Key Bindings ######

" Load Windows keybindings on all platforms except OS-X GUI
"   Maps the usual suspects: Ctrl-{A,C,S,V,X,Y,Z}
if has("gui_macvim") == 0
    source $VIMRUNTIME/mswin.vim

    " Let arrow keys work with visual select
    set keymodel-=stopsel
endif

" C-V -- Gvim: paste                                            [All Modes]
"    Terminal: enter Visual Block mode               [Normal / Visual Mode]
"    Terminal: insert literal character                       [Insert Mode]
" C-Q -- Gvim: enter Visual Block mode               [Normal / Visual Mode]
"        Gvim: insert literal character                       [Insert Mode]
if has("gui_running") == 0 && ! empty(maparg('<C-V>'))
    unmap <C-V>
    iunmap <C-V>
endif

" C-Y -- scroll window upwards                       [Normal / Visual Mode]
if ! empty(maparg('<C-Y>'))
    unmap <C-Y>
endif

" C-Z -- Gvim: undo                                             [All Modes]
"    Terminal: suspend vim and return to shell       [Normal / Visual Mode]
if has("gui_running") == 0 && ! empty(maparg('<C-Z>'))
    unmap <C-Z>
    " Technically <C-Z> still performs undo in Terminal during insert mode
endif

" C-/ -- Terminal: toggle whether line is commented  [Normal / Visual Mode]
"   (Only works in terminals where <C-/> is equivalent to <C-_>)
noremap <silent> <C-_> :Commentary<CR>

" & -- repeate last `:s` substitute (preserves flags)
nnoremap & :&&<CR>
xnoremap & :&&<CR>

" Y -- yank to end of line; see `:help Y`                     [Normal Mode]
nnoremap Y y$

" Enter key -- insert a new line above the current            [Normal Mode]
nnoremap <CR> O<Esc>j
" ...but not in the Command-line window (solution by Ingo Karkat [2])
autocmd CmdwinEnter * nnoremap <buffer> <CR> <CR>
" ...nor in the Quickfix window
autocmd BufReadPost * if &buftype ==# 'quickfix' | nnoremap <buffer> <CR> <CR> | endif

" Ctrl-Tab -- Gvim: switch to next tab                        [Normal Mode]
nnoremap <silent> <C-Tab> :tabnext<CR>

" Ctrl-Shift-Tab -- Gvim: switch to previous tab              [Normal Mode]
nnoremap <silent> <C-S-Tab> :tabprev<CR>

" Q{motion} -- format specified lines                [Normal / Visual Mode]
noremap Q gq

" j -- move down one line on the screen              [Normal / Visual Mode]
nnoremap j gj
vnoremap j gj

" gj -- move down one line in the file               [Normal / Visual Mode]
nnoremap gj j
vnoremap gj j

" k -- move up one line on the screen                [Normal / Visual Mode]
nnoremap k gk
vnoremap k gk

" gk -- move up one line in the file                 [Normal / Visual Mode]
nnoremap gk k
vnoremap gk k

" > -- shift selection rightwards (preserve selection)        [Visual Mode]
vnoremap > >gv

" < -- shift selection leftwards (preserve selection)         [Visual Mode]
vnoremap < <gv

nnoremap J :tabprevious<CR>
nnoremap K :tabnext<CR>
nnoremap <C-j> :join<CR>
nnoremap <C-f> :let @/ = @"<CR>|  " Find yanked text
set pastetoggle=<F2>

" Insert current date header in markdown files
nnoremap <F5> "=strftime("## %Y-%m-%d")<CR>P
inoremap <F5> <C-R>=strftime("## %Y-%m-%d")<CR>

" Tab -- indent at beginning of line, otherwise autocomplete  [Insert Mode]
inoremap <silent> <Tab> <C-R>=DwiwITab()<cr>
inoremap <silent> <S-Tab> <C-N>

" Taken from Gary Bernhardt's vimrc [1]
function! DwiwITab()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    else
        return "\<c-p>"
    endif
endfunction

" Allow . to apply to every line in visual selection
vnoremap . :normal .<CR>

" Vim settings
set clipboard=unnamed
set hidden|     " Let user switch away from buffers with unsaved changes
set hlsearch    " Highlight search term matches

" Disable audio bell
set visualbell t_vb=
autocmd GUIEnter * set t_vb=


" Display settings
set number
set guifont=Consolas:h11:cANSI| " Fix molokai italics/gui only
set cursorline
set showmatch matchtime=3|  " tenths of a second to show matching parens
if has("gui_running")
    colorscheme molokai
else
    set background=dark
endif

" Spacing and tabbing
set smarttab
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set wrap
set formatoptions-=t

" ##### Backup, swap and undo file settings #####
let s:vimfiles = $HOME . '/.vim'

" Backup -- when overwriting a file, take a backup copy
set backup
let &backupdir = s:vimfiles . '/tmp/backup//'
if !isdirectory(expand(&backupdir))
    call mkdir(expand(&backupdir), "p")
endif
"
" Move swap files to $HOME/.vim/tmp/swp
let &directory = s:vimfiles . '/tmp/swp//'
if !isdirectory(expand(&directory))
    call mkdir(expand(&directory), "p")
endif
"
" Undofile -- keep a file to persist undo history after file is closed
if has("persistent_undo") == 1
    set undofile
    let &undodir = s:vimfiles . '/tmp/undo//'
    if !isdirectory(expand(&undodir))
        call mkdir(expand(&undodir), "p")
    endif
endif

" Filetypes
autocmd BufEnter,BufRead,BufNewFile *.txt setfiletype txt
autocmd FileType pau FileType css set omnifunc=csscomplete#CompleteCSS
autocmd FileType html,xhtml,xml set omnifunc=htmlcomplete#CompleteTags tw=0
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python set omnifunc=pythoncomplete#Complete et sw=4 sts=4 ts=4 ai
autocmd BufNewFile,BufRead *.lss set filetype=less
autocmd BufNewFile,BufRead *.less set filetype=less
autocmd BufNewFile,BufRead *.css set filetype=less
autocmd FileType markdown,txt set formatoptions-=t

" Autocmd utilities
autocmd BufEnter * silent! lcd %:p:h|                           " cd to opened file location
autocmd FocusLost,TabLeave * call feedkeys("\<C-\>\<C-n>")|     " Normal mode on focus lost
autocmd FileType c,cpp,java,php,python,javascript,json,ruby,markdown autocmd BufWritePre * :%s/\s\+$//e
autocmd FileType xml setlocal equalprg=xmllint\ --format\ --recover\ -\ 2>/dev/null

"python with virtualenv support
"py << EOF
"import os
"import sys
" if 'VIRTUAL_ENV' in os.environ:
"     project_base_dir = os.environ['VIRTUAL_ENV']
"     activate_this = os.path.join(project_base_dir, 'bin/activate_this.py')
"     execfile(activate_this, dict(__file__=activate_this))
" EOF

" NerdTree Settings
autocmd VimEnter * nmap <F3> cd %:p:h<CR>|:NERDTreeToggle<CR>
autocmd VimEnter * imap <F3> <Esc>:NERDTreeToggle<CR>a
let NERDTreeQuitOnOpen=1
let NERDTreeWinSize=50
let NERDTreeShowHidden=1

" Ctrl-P Settings
let g:ctrlp_map='<c-p>'
let g:ctrlp_cmd = 'CtrlPMRU'|  " Start Ctrl P in MRU mode
map <C-B> :CtrlPBuffer<CR>

" vim-airline Settings
let g:airline#extensions#tabline#enabled = 1
set noshowmode  " vim-airline displays the mode

" flake8 Settings
autocmd FileType python map <buffer> <F5> :call Flake8()<CR>
autocmd BufWritePost *.py call Flake8()

" Tabular Settings
inoremap <silent> <Bar>   <Bar><Esc>:call <SID>align()<CR>a

function! s:align()
  let p = '^\s*|\s.*\s|\s*$'
  if exists(':Tabularize') && getline('.') =~# '^\s*|' && (getline(line('.')-1) =~# p || getline(line('.')+1) =~# p)
    let column = strlen(substitute(getline('.')[0:col('.')],'[^|]','','g'))
    let position = strlen(matchstr(getline('.')[0:col('.')],'.*|\s*\zs.*'))
    Tabularize/|/l1
    normal! 0
    call search(repeat('[^|]*|',column).'\s\{-\}'.repeat('.',position),'ce',line('.'))
  endif
endfunction

" Diff buffers
" https://stackoverflow.com/questions/3619146/vimdiff-two-subroutines-in-same-file/3621806#3621806
let g:diffed_buffers=[]
function DiffText(a, b, diffed_buffers)
    enew
    setlocal buftype=nowrite
    call add(a:diffed_buffers, bufnr('%'))
    call setline(1, split(a:a, "\n"))
    diffthis
    vnew
    setlocal buftype=nowrite
    call add(a:diffed_buffers, bufnr('%'))
    call setline(1, split(a:b, "\n"))
    diffthis
endfunction
function WipeOutDiffs(diffed_buffers)
    for buffer in a:diffed_buffers
        execute 'bwipeout! '.buffer
    endfor
endfunction
nnoremap <special> <C-d> :call DiffText(@a, @b, g:diffed_buffers)<CR>

nnoremap <special> <C-d><C-d> :call WipeOutDiffs(g:diffed_buffers) <bar> let g:diffed_buffers=[]<CR>

function! FormatJson()
    %!jq .
    if v:shell_error
        let error=getline(1)
        undo
        echohl WarningMsg | echom error | echohl none
    endif
endfunction
nnoremap <Leader>j :call FormatJson()<cr>

" Use smart case for searching
set ignorecase
set smartcase


