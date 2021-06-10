let SessionLoad = 1
if &cp | set nocp | endif
let s:cpo_save=&cpo
set cpo&vim
imap <C-G>S <Plug>ISurround
imap <C-G>s <Plug>Isurround
imap <C-S> <Plug>Isurround
inoremap <F2> =strftime("%m/%d/%Y") 
map! <S-Insert> *
nnoremap  h
nnoremap <NL> j
nnoremap  k
nnoremap  l
vmap  "*d
nnoremap  g
omap <silent> % <Plug>(MatchitOperationForward)
xmap <silent> % <Plug>(MatchitVisualForward)
nmap <silent> % <Plug>(MatchitNormalForward)
nnoremap ,l o--------------------------------------------------------------------------------
nnoremap ,yf :let @+=@%
nnoremap ,yp :redir @+:pwd:redir end:let @+=@+."\\":let @+=@+.@%
nnoremap ,yW "+yiW
nnoremap ,yw "+yiw
vnoremap ,y "+y
nnoremap ,a ggVG
nnoremap ,t :tab split
nnoremap ,w :w
nnoremap ,cd :cd %:p:h:pwd
nnoremap ,x :simalt ~x
nnoremap ,bu :!cp -R "C:/Users/1021887/_vimrc" "S:/Team Members/IngAllan/vim":!cp -R "C:/Users/1021887/vimfiles" "S:/Team Members/IngAllan/vim"
nnoremap ,s :source ~\_vimrc
nnoremap ,v :e ~\_vimrc
vnoremap < <gv
vnoremap > >gv
xmap S <Plug>VSurround
map [] k$][%?}
map [[ ?{w99[{
omap <silent> [% <Plug>(MatchitOperationMultiBackward)
xmap <silent> [% <Plug>(MatchitVisualMultiBackward)
nmap <silent> [% <Plug>(MatchitNormalMultiBackward)
map ]] j0[[%/{
map ][ /}b99]}
omap <silent> ]% <Plug>(MatchitOperationMultiForward)
xmap <silent> ]% <Plug>(MatchitVisualMultiForward)
nmap <silent> ]% <Plug>(MatchitNormalMultiForward)
xmap a% <Plug>(MatchitVisualTextObject)
nmap cS <Plug>CSurround
nmap cs <Plug>Csurround
nmap ds <Plug>Dsurround
vmap gx <Plug>NetrwBrowseXVis
nmap gx <Plug>NetrwBrowseX
xmap gS <Plug>VgSurround
omap <silent> g% <Plug>(MatchitOperationBackward)
xmap <silent> g% <Plug>(MatchitVisualBackward)
nmap <silent> g% <Plug>(MatchitNormalBackward)
nmap ySS <Plug>YSsurround
nmap ySs <Plug>YSsurround
nmap yss <Plug>Yssurround
nmap yS <Plug>YSurround
nmap ys <Plug>Ysurround
vnoremap <silent> <Plug>NetrwBrowseXVis :call netrw#BrowseXVis()
nnoremap <silent> <Plug>NetrwBrowseX :call netrw#BrowseX(netrw#GX(),netrw#CheckIfRemote(netrw#GX()))
nnoremap <silent> <Plug>SurroundRepeat .
nmap <F8> :TagbarToggle
nnoremap <F2> ^"=strftime("%m/%d/%Y")Pa 
nnoremap <M-Left> :cp
nnoremap <M-Right> :cn
nnoremap <C-S-Tab> :bp
nnoremap <C-Tab> :bn
nnoremap <C-L> l
nnoremap <C-H> h
nnoremap <C-K> k
nnoremap <C-J> j
nnoremap <C-]> g
xmap <silent> <Plug>(MatchitVisualTextObject) <Plug>(MatchitVisualMultiBackward)o<Plug>(MatchitVisualMultiForward)
onoremap <silent> <Plug>(MatchitOperationMultiForward) :call matchit#MultiMatch("W",  "o")
onoremap <silent> <Plug>(MatchitOperationMultiBackward) :call matchit#MultiMatch("bW", "o")
xnoremap <silent> <Plug>(MatchitVisualMultiForward) :call matchit#MultiMatch("W",  "n")m'gv``
xnoremap <silent> <Plug>(MatchitVisualMultiBackward) :call matchit#MultiMatch("bW", "n")m'gv``
nnoremap <silent> <Plug>(MatchitNormalMultiForward) :call matchit#MultiMatch("W",  "n")
nnoremap <silent> <Plug>(MatchitNormalMultiBackward) :call matchit#MultiMatch("bW", "n")
onoremap <silent> <Plug>(MatchitOperationBackward) :call matchit#Match_wrapper('',0,'o')
onoremap <silent> <Plug>(MatchitOperationForward) :call matchit#Match_wrapper('',1,'o')
xnoremap <silent> <Plug>(MatchitVisualBackward) :call matchit#Match_wrapper('',0,'v')m'gv``
xnoremap <silent> <Plug>(MatchitVisualForward) :call matchit#Match_wrapper('',1,'v')m'gv``
nnoremap <silent> <Plug>(MatchitNormalBackward) :call matchit#Match_wrapper('',0,'n')
nnoremap <silent> <Plug>(MatchitNormalForward) :call matchit#Match_wrapper('',1,'n')
vmap <C-X> "*d
vmap <C-Del> "*d
vmap <S-Del> "*d
vmap <C-Insert> "*y
vmap <S-Insert> "-d"*P
nmap <S-Insert> "*P
imap S <Plug>ISurround
imap s <Plug>Isurround
imap  <Plug>Isurround
inoremap jk 
iabbr gu local Util = require(ReplicatedStorage.Util)
iabbr gpr local Promise = require(ReplicatedStorage.Vendor.Promise)
iabbr gpl local Players = game:GetService("Players")
iabbr gss local ServerStorage = game:GetService("ServerStorage")
iabbr grs local ReplicatedStorage = game:GetService("ReplicatedStorage")
iabbr gws local Workspace = game:GetService("Workspace")
iabbr gs game:GetService("
iabbr wfc WaitForChild("
iabbr ffc FindFirstChild("
let &cpo=s:cpo_save
unlet s:cpo_save
set autochdir
set background=dark
set backspace=indent,eol,start
set backupdir=C:\\temp,C:\\RTN,.
set cmdheight=2
set completeopt=menu,preview,longest
set cscopeprg=C:\\cygwin64\\bin\\cscope.exe
set directory=C:\\temp,C:\\RTN,.
set expandtab
set grepprg=C:\\cygwin64\\bin\\grep.exe\ -nH
set guifont=courier_new:h9
set guioptions=egmrLt
set helplang=En
set hidden
set hlsearch
set ignorecase
set incsearch
set laststatus=2
set listchars=tab:>-,trail:-
set ruler
set runtimepath=~\\dotfiles\\vimfiles\\bundle\\surround,~\\dotfiles\\vimfiles\\bundle\\tabular-master,~/vimfiles,~\\vimfiles\\bundle\\vim-lua-ftplugin-master,~\\vimfiles\\bundle\\vim-misc-master,C:\\Program\ Files\ (x86)\\Vim/vimfiles,C:\\Program\ Files\ (x86)\\Vim\\vim82,C:\\Program\ Files\ (x86)\\Vim\\vim82\\pack\\dist\\opt\\matchit,C:\\Program\ Files\ (x86)\\Vim/vimfiles/after,~/vimfiles/after,~\\dotfiles\\vimfiles\\bundle\\tabular-master\\after
set scrolloff=1
set shiftwidth=2
set showtabline=2
set smartcase
set smartindent
set softtabstop=2
set statusline=%<%f\ (%{&ft})\ %-4(%m%)%r%=buf=%-4n0x%-4.8B%-14(%3l,%02c%03V%)%<%P
set tabstop=2
set tags=./tags,tags,tags;/,D:\\rtn\\windriver\\3.9\\vxworks-6.9\\target\\h\\tags
set window=60
set nowritebackup
let s:so_save = &so | let s:siso_save = &siso | set so=0 siso=0
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd C:\Data\Roblox\Places\PetShopPanic
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
set shortmess=aoO
argglobal
%argdel
$argadd src\ServerScriptService\BuyDeveloperProduct.server.lua
tabnew
tabnew
tabrewind
edit C:\Data\Roblox\Places\PetShopPanic\default.project.json
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd w
wincmd _ | wincmd |
split
1wincmd k
wincmd w
set nosplitbelow
set nosplitright
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe 'vert 1resize ' . ((&columns * 134 + 134) / 269)
exe '2resize ' . ((&lines * 29 + 30) / 61)
exe 'vert 2resize ' . ((&columns * 134 + 134) / 269)
exe '3resize ' . ((&lines * 28 + 30) / 61)
exe 'vert 3resize ' . ((&columns * 134 + 134) / 269)
argglobal
setlocal keymap=
setlocal noarabic
setlocal noautoindent
setlocal backupcopy=
setlocal balloonexpr=
setlocal nobinary
setlocal nobreakindent
setlocal breakindentopt=
setlocal bufhidden=
setlocal buflisted
setlocal buftype=
setlocal nocindent
setlocal cinkeys=0{,0},0),0],:,0#,!^F,o,O,e
setlocal cinoptions=
setlocal cinwords=if,else,while,do,for,switch
setlocal colorcolumn=
setlocal comments=
setlocal commentstring=
setlocal complete=.,w,b,u,t,i
setlocal concealcursor=
setlocal conceallevel=0
setlocal completefunc=
setlocal completeslash=
setlocal nocopyindent
setlocal cryptmethod=
setlocal nocursorbind
setlocal nocursorcolumn
set cursorline
setlocal cursorline
setlocal cursorlineopt=both
setlocal define=
setlocal dictionary=
setlocal nodiff
setlocal equalprg=
setlocal errorformat=
setlocal expandtab
if &filetype != 'json'
setlocal filetype=json
endif
setlocal fixendofline
setlocal foldcolumn=0
setlocal foldenable
setlocal foldexpr=0
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldmarker={{{,}}}
setlocal foldmethod=manual
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal foldtext=foldtext()
setlocal formatexpr=
setlocal formatoptions=tcq
setlocal formatlistpat=^\\s*\\d\\+[\\]:.)}\\t\ ]\\s*
setlocal formatprg=
setlocal grepprg=
setlocal iminsert=0
setlocal imsearch=-1
setlocal include=
setlocal includeexpr=
setlocal indentexpr=GetJSONIndent()
setlocal indentkeys=0{,0},0),0[,0],!^F,o,O,e
setlocal noinfercase
setlocal iskeyword=@,48-57,_,192-255
setlocal keywordprg=
setlocal nolinebreak
setlocal nolisp
setlocal lispwords=
set list
setlocal list
setlocal makeencoding=
setlocal makeprg=
setlocal matchpairs=(:),{:},[:]
setlocal modeline
setlocal modifiable
setlocal nrformats=bin,octal,hex
setlocal nonumber
setlocal numberwidth=4
setlocal omnifunc=
setlocal path=
setlocal nopreserveindent
setlocal nopreviewwindow
setlocal quoteescape=\\
setlocal noreadonly
set relativenumber
setlocal relativenumber
setlocal norightleft
setlocal rightleftcmd=search
setlocal noscrollbind
setlocal scrolloff=-1
setlocal shiftwidth=2
setlocal noshortname
setlocal showbreak=
setlocal sidescrolloff=-1
setlocal signcolumn=auto
setlocal smartindent
setlocal softtabstop=2
setlocal nospell
setlocal spellcapcheck=[.?!]\\_[\\])'\"\	\ ]\\+
setlocal spellfile=
setlocal spelllang=en
setlocal statusline=
setlocal suffixesadd=
setlocal swapfile
setlocal synmaxcol=3000
if &syntax != 'json'
setlocal syntax=json
endif
setlocal tabstop=2
setlocal tagcase=
setlocal tagfunc=
setlocal tags=
setlocal termwinkey=
setlocal termwinscroll=10000
setlocal termwinsize=
setlocal textwidth=0
setlocal thesaurus=
setlocal noundofile
setlocal undolevels=-123456
setlocal varsofttabstop=
setlocal vartabstop=
setlocal wincolor=
setlocal nowinfixheight
setlocal nowinfixwidth
setlocal wrap
setlocal wrapmargin=0
silent! normal! zE
let s:l = 23 - ((22 * winheight(0) + 29) / 58)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
23
normal! 0
wincmd w
argglobal
if bufexists("C:\Data\Roblox\Places\PetShopPanic\src\ReplicatedStorage\Session.lua") | buffer C:\Data\Roblox\Places\PetShopPanic\src\ReplicatedStorage\Session.lua | else | edit C:\Data\Roblox\Places\PetShopPanic\src\ReplicatedStorage\Session.lua | endif
let s:cpo_save=&cpo
set cpo&vim
imap <buffer> <F1> :call xolox#lua#help()
nmap <buffer> K :call xolox#lua#help()
noremap <buffer> <silent> [] m':call xolox#lua#jumpotherfunc(0)
noremap <buffer> <silent> [[ m':call xolox#lua#jumpthisfunc(0)
noremap <buffer> <silent> [{ m':call xolox#lua#jumpblock(0)
noremap <buffer> <silent> ]] m':call xolox#lua#jumpotherfunc(1)
noremap <buffer> <silent> ][ m':call xolox#lua#jumpthisfunc(1)
noremap <buffer> <silent> ]} m':call xolox#lua#jumpblock(1)
nmap <buffer> <F1> :call xolox#lua#help()
inoremap <buffer> <silent> <expr> " xolox#lua#completedynamic('"')
inoremap <buffer> <silent> <expr> ' xolox#lua#completedynamic("'")
inoremap <buffer> <silent> <expr> . xolox#lua#completedynamic('.')
let &cpo=s:cpo_save
unlet s:cpo_save
setlocal keymap=
setlocal noarabic
setlocal autoindent
setlocal backupcopy=
setlocal balloonexpr=xolox#lua#getsignature(v:beval_text)
setlocal nobinary
setlocal nobreakindent
setlocal breakindentopt=
setlocal bufhidden=
setlocal buflisted
setlocal buftype=
setlocal nocindent
setlocal cinkeys=0{,0},0),0],:,0#,!^F,o,O,e
setlocal cinoptions=
setlocal cinwords=if,else,while,do,for,switch
setlocal colorcolumn=
setlocal comments=s:--[[,m:\ ,e:]],:--
setlocal commentstring=--%s
setlocal complete=.,w,b,u,t,i
setlocal concealcursor=
setlocal conceallevel=0
setlocal completefunc=xolox#lua#completefunc
setlocal completeslash=
setlocal nocopyindent
setlocal cryptmethod=
setlocal nocursorbind
setlocal nocursorcolumn
set cursorline
setlocal cursorline
setlocal cursorlineopt=both
setlocal define=
setlocal dictionary=
setlocal nodiff
setlocal equalprg=
setlocal errorformat=
setlocal expandtab
if &filetype != 'lua'
setlocal filetype=lua
endif
setlocal fixendofline
setlocal foldcolumn=0
setlocal foldenable
setlocal foldexpr=0
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldmarker={{{,}}}
setlocal foldmethod=manual
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal foldtext=foldtext()
setlocal formatexpr=
setlocal formatoptions=croql
setlocal formatlistpat=^\\s*\\d\\+[\\]:.)}\\t\ ]\\s*
setlocal formatprg=
setlocal grepprg=
setlocal iminsert=0
setlocal imsearch=-1
setlocal include=\\v<((do|load)file|require)[^'\"]*['\"]\\zs[^'\"]+
setlocal includeexpr=xolox#lua#includeexpr(v:fname)
setlocal indentexpr=GetLuaIndent()
setlocal indentkeys=0{,0},0),0],:,0#,!^F,o,O,e,0=end,0=until,0=elseif,0=else
setlocal noinfercase
setlocal iskeyword=@,48-57,_,192-255
setlocal keywordprg=
setlocal nolinebreak
setlocal nolisp
setlocal lispwords=
set list
setlocal list
setlocal makeencoding=
setlocal makeprg=
setlocal matchpairs=(:),{:},[:]
setlocal modeline
setlocal modifiable
setlocal nrformats=bin,octal,hex
setlocal nonumber
setlocal numberwidth=4
setlocal omnifunc=xolox#lua#omnifunc
setlocal path=
setlocal nopreserveindent
setlocal nopreviewwindow
setlocal quoteescape=\\
setlocal noreadonly
set relativenumber
setlocal relativenumber
setlocal norightleft
setlocal rightleftcmd=search
setlocal noscrollbind
setlocal scrolloff=-1
setlocal shiftwidth=2
setlocal noshortname
setlocal showbreak=
setlocal sidescrolloff=-1
setlocal signcolumn=auto
setlocal nosmartindent
setlocal softtabstop=2
setlocal nospell
setlocal spellcapcheck=[.?!]\\_[\\])'\"\	\ ]\\+
setlocal spellfile=
setlocal spelllang=en
setlocal statusline=
setlocal suffixesadd=
setlocal swapfile
setlocal synmaxcol=3000
if &syntax != 'lua'
setlocal syntax=lua
endif
setlocal tabstop=2
setlocal tagcase=
setlocal tagfunc=
setlocal tags=
setlocal termwinkey=
setlocal termwinscroll=10000
setlocal termwinsize=
setlocal textwidth=0
setlocal thesaurus=
setlocal noundofile
setlocal undolevels=-123456
setlocal varsofttabstop=
setlocal vartabstop=
setlocal wincolor=
setlocal nowinfixheight
setlocal nowinfixwidth
setlocal wrap
setlocal wrapmargin=0
silent! normal! zE
let s:l = 1 - ((0 * winheight(0) + 14) / 29)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
1
normal! 0
wincmd w
argglobal
if bufexists("C:\Data\Roblox\Places\PetShopPanic\src\ServerScriptService\PlayerManager.lua") | buffer C:\Data\Roblox\Places\PetShopPanic\src\ServerScriptService\PlayerManager.lua | else | edit C:\Data\Roblox\Places\PetShopPanic\src\ServerScriptService\PlayerManager.lua | endif
let s:cpo_save=&cpo
set cpo&vim
imap <buffer> <F1> :call xolox#lua#help()
nmap <buffer> K :call xolox#lua#help()
noremap <buffer> <silent> [] m':call xolox#lua#jumpotherfunc(0)
noremap <buffer> <silent> [[ m':call xolox#lua#jumpthisfunc(0)
noremap <buffer> <silent> [{ m':call xolox#lua#jumpblock(0)
noremap <buffer> <silent> ]] m':call xolox#lua#jumpotherfunc(1)
noremap <buffer> <silent> ][ m':call xolox#lua#jumpthisfunc(1)
noremap <buffer> <silent> ]} m':call xolox#lua#jumpblock(1)
nmap <buffer> <F1> :call xolox#lua#help()
inoremap <buffer> <silent> <expr> " xolox#lua#completedynamic('"')
inoremap <buffer> <silent> <expr> ' xolox#lua#completedynamic("'")
inoremap <buffer> <silent> <expr> . xolox#lua#completedynamic('.')
let &cpo=s:cpo_save
unlet s:cpo_save
setlocal keymap=
setlocal noarabic
setlocal autoindent
setlocal backupcopy=
setlocal balloonexpr=xolox#lua#getsignature(v:beval_text)
setlocal nobinary
setlocal nobreakindent
setlocal breakindentopt=
setlocal bufhidden=
setlocal buflisted
setlocal buftype=
setlocal nocindent
setlocal cinkeys=0{,0},0),0],:,0#,!^F,o,O,e
setlocal cinoptions=
setlocal cinwords=if,else,while,do,for,switch
setlocal colorcolumn=
setlocal comments=s:--[[,m:\ ,e:]],:--
setlocal commentstring=--%s
setlocal complete=.,w,b,u,t,i
setlocal concealcursor=
setlocal conceallevel=0
setlocal completefunc=xolox#lua#completefunc
setlocal completeslash=
setlocal nocopyindent
setlocal cryptmethod=
setlocal nocursorbind
setlocal nocursorcolumn
set cursorline
setlocal cursorline
setlocal cursorlineopt=both
setlocal define=
setlocal dictionary=
setlocal nodiff
setlocal equalprg=
setlocal errorformat=
setlocal expandtab
if &filetype != 'lua'
setlocal filetype=lua
endif
setlocal fixendofline
setlocal foldcolumn=0
setlocal foldenable
setlocal foldexpr=0
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldmarker={{{,}}}
setlocal foldmethod=manual
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal foldtext=foldtext()
setlocal formatexpr=
setlocal formatoptions=croql
setlocal formatlistpat=^\\s*\\d\\+[\\]:.)}\\t\ ]\\s*
setlocal formatprg=
setlocal grepprg=
setlocal iminsert=0
setlocal imsearch=-1
setlocal include=\\v<((do|load)file|require)[^'\"]*['\"]\\zs[^'\"]+
setlocal includeexpr=xolox#lua#includeexpr(v:fname)
setlocal indentexpr=GetLuaIndent()
setlocal indentkeys=0{,0},0),0],:,0#,!^F,o,O,e,0=end,0=until,0=elseif,0=else
setlocal noinfercase
setlocal iskeyword=@,48-57,_,192-255
setlocal keywordprg=
setlocal nolinebreak
setlocal nolisp
setlocal lispwords=
set list
setlocal list
setlocal makeencoding=
setlocal makeprg=
setlocal matchpairs=(:),{:},[:]
setlocal modeline
setlocal modifiable
setlocal nrformats=bin,octal,hex
setlocal nonumber
setlocal numberwidth=4
setlocal omnifunc=xolox#lua#omnifunc
setlocal path=
setlocal nopreserveindent
setlocal nopreviewwindow
setlocal quoteescape=\\
setlocal noreadonly
set relativenumber
setlocal relativenumber
setlocal norightleft
setlocal rightleftcmd=search
setlocal noscrollbind
setlocal scrolloff=-1
setlocal shiftwidth=2
setlocal noshortname
setlocal showbreak=
setlocal sidescrolloff=-1
setlocal signcolumn=auto
setlocal nosmartindent
setlocal softtabstop=2
setlocal nospell
setlocal spellcapcheck=[.?!]\\_[\\])'\"\	\ ]\\+
setlocal spellfile=
setlocal spelllang=en
setlocal statusline=
setlocal suffixesadd=
setlocal swapfile
setlocal synmaxcol=3000
if &syntax != 'lua'
setlocal syntax=lua
endif
setlocal tabstop=2
setlocal tagcase=
setlocal tagfunc=
setlocal tags=
setlocal termwinkey=
setlocal termwinscroll=10000
setlocal termwinsize=
setlocal textwidth=0
setlocal thesaurus=
setlocal noundofile
setlocal undolevels=-123456
setlocal varsofttabstop=
setlocal vartabstop=
setlocal wincolor=
setlocal nowinfixheight
setlocal nowinfixwidth
setlocal wrap
setlocal wrapmargin=0
silent! normal! zE
let s:l = 66 - ((13 * winheight(0) + 14) / 28)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
66
normal! 074|
wincmd w
exe 'vert 1resize ' . ((&columns * 134 + 134) / 269)
exe '2resize ' . ((&lines * 29 + 30) / 61)
exe 'vert 2resize ' . ((&columns * 134 + 134) / 269)
exe '3resize ' . ((&lines * 28 + 30) / 61)
exe 'vert 3resize ' . ((&columns * 134 + 134) / 269)
tabnext
edit C:\Data\Roblox\Places\PetShopPanic\src\ServerScriptService\MapManager.lua
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd w
wincmd _ | wincmd |
split
1wincmd k
wincmd w
set nosplitbelow
set nosplitright
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe 'vert 1resize ' . ((&columns * 134 + 134) / 269)
exe '2resize ' . ((&lines * 29 + 30) / 61)
exe 'vert 2resize ' . ((&columns * 134 + 134) / 269)
exe '3resize ' . ((&lines * 28 + 30) / 61)
exe 'vert 3resize ' . ((&columns * 134 + 134) / 269)
argglobal
let s:cpo_save=&cpo
set cpo&vim
imap <buffer> <F1> :call xolox#lua#help()
nmap <buffer> K :call xolox#lua#help()
noremap <buffer> <silent> [] m':call xolox#lua#jumpotherfunc(0)
noremap <buffer> <silent> [[ m':call xolox#lua#jumpthisfunc(0)
noremap <buffer> <silent> [{ m':call xolox#lua#jumpblock(0)
noremap <buffer> <silent> ]] m':call xolox#lua#jumpotherfunc(1)
noremap <buffer> <silent> ][ m':call xolox#lua#jumpthisfunc(1)
noremap <buffer> <silent> ]} m':call xolox#lua#jumpblock(1)
nmap <buffer> <F1> :call xolox#lua#help()
inoremap <buffer> <silent> <expr> " xolox#lua#completedynamic('"')
inoremap <buffer> <silent> <expr> ' xolox#lua#completedynamic("'")
inoremap <buffer> <silent> <expr> . xolox#lua#completedynamic('.')
let &cpo=s:cpo_save
unlet s:cpo_save
setlocal keymap=
setlocal noarabic
setlocal autoindent
setlocal backupcopy=
setlocal balloonexpr=xolox#lua#getsignature(v:beval_text)
setlocal nobinary
setlocal nobreakindent
setlocal breakindentopt=
setlocal bufhidden=
setlocal buflisted
setlocal buftype=
setlocal nocindent
setlocal cinkeys=0{,0},0),0],:,0#,!^F,o,O,e
setlocal cinoptions=
setlocal cinwords=if,else,while,do,for,switch
setlocal colorcolumn=
setlocal comments=s:--[[,m:\ ,e:]],:--
setlocal commentstring=--%s
setlocal complete=.,w,b,u,t,i
setlocal concealcursor=
setlocal conceallevel=0
setlocal completefunc=xolox#lua#completefunc
setlocal completeslash=
setlocal nocopyindent
setlocal cryptmethod=
setlocal nocursorbind
setlocal nocursorcolumn
set cursorline
setlocal cursorline
setlocal cursorlineopt=both
setlocal define=
setlocal dictionary=
setlocal nodiff
setlocal equalprg=
setlocal errorformat=
setlocal expandtab
if &filetype != 'lua'
setlocal filetype=lua
endif
setlocal fixendofline
setlocal foldcolumn=0
setlocal foldenable
setlocal foldexpr=0
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldmarker={{{,}}}
setlocal foldmethod=manual
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal foldtext=foldtext()
setlocal formatexpr=
setlocal formatoptions=croql
setlocal formatlistpat=^\\s*\\d\\+[\\]:.)}\\t\ ]\\s*
setlocal formatprg=
setlocal grepprg=
setlocal iminsert=0
setlocal imsearch=-1
setlocal include=\\v<((do|load)file|require)[^'\"]*['\"]\\zs[^'\"]+
setlocal includeexpr=xolox#lua#includeexpr(v:fname)
setlocal indentexpr=GetLuaIndent()
setlocal indentkeys=0{,0},0),0],:,0#,!^F,o,O,e,0=end,0=until,0=elseif,0=else
setlocal noinfercase
setlocal iskeyword=@,48-57,_,192-255
setlocal keywordprg=
setlocal nolinebreak
setlocal nolisp
setlocal lispwords=
set list
setlocal list
setlocal makeencoding=
setlocal makeprg=
setlocal matchpairs=(:),{:},[:]
setlocal modeline
setlocal modifiable
setlocal nrformats=bin,octal,hex
setlocal nonumber
setlocal numberwidth=4
setlocal omnifunc=xolox#lua#omnifunc
setlocal path=
setlocal nopreserveindent
setlocal nopreviewwindow
setlocal quoteescape=\\
setlocal noreadonly
set relativenumber
setlocal relativenumber
setlocal norightleft
setlocal rightleftcmd=search
setlocal noscrollbind
setlocal scrolloff=-1
setlocal shiftwidth=2
setlocal noshortname
setlocal showbreak=
setlocal sidescrolloff=-1
setlocal signcolumn=auto
setlocal nosmartindent
setlocal softtabstop=2
setlocal nospell
setlocal spellcapcheck=[.?!]\\_[\\])'\"\	\ ]\\+
setlocal spellfile=
setlocal spelllang=en
setlocal statusline=
setlocal suffixesadd=
setlocal swapfile
setlocal synmaxcol=3000
if &syntax != 'lua'
setlocal syntax=lua
endif
setlocal tabstop=2
setlocal tagcase=
setlocal tagfunc=
setlocal tags=
setlocal termwinkey=
setlocal termwinscroll=10000
setlocal termwinsize=
setlocal textwidth=0
setlocal thesaurus=
setlocal noundofile
setlocal undolevels=-123456
setlocal varsofttabstop=
setlocal vartabstop=
setlocal wincolor=
setlocal nowinfixheight
setlocal nowinfixwidth
setlocal wrap
setlocal wrapmargin=0
silent! normal! zE
let s:l = 1 - ((0 * winheight(0) + 29) / 58)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
1
normal! 0
lcd C:\Data\Roblox\Places\PetShopPanic\src\StarterGui
wincmd w
argglobal
if bufexists("C:\Data\Roblox\Places\PetShopPanic\src\ReplicatedStorage\Globals.lua") | buffer C:\Data\Roblox\Places\PetShopPanic\src\ReplicatedStorage\Globals.lua | else | edit C:\Data\Roblox\Places\PetShopPanic\src\ReplicatedStorage\Globals.lua | endif
let s:cpo_save=&cpo
set cpo&vim
imap <buffer> <F1> :call xolox#lua#help()
nmap <buffer> K :call xolox#lua#help()
noremap <buffer> <silent> [] m':call xolox#lua#jumpotherfunc(0)
noremap <buffer> <silent> [[ m':call xolox#lua#jumpthisfunc(0)
noremap <buffer> <silent> [{ m':call xolox#lua#jumpblock(0)
noremap <buffer> <silent> ]] m':call xolox#lua#jumpotherfunc(1)
noremap <buffer> <silent> ][ m':call xolox#lua#jumpthisfunc(1)
noremap <buffer> <silent> ]} m':call xolox#lua#jumpblock(1)
nmap <buffer> <F1> :call xolox#lua#help()
inoremap <buffer> <silent> <expr> " xolox#lua#completedynamic('"')
inoremap <buffer> <silent> <expr> ' xolox#lua#completedynamic("'")
inoremap <buffer> <silent> <expr> . xolox#lua#completedynamic('.')
let &cpo=s:cpo_save
unlet s:cpo_save
setlocal keymap=
setlocal noarabic
setlocal autoindent
setlocal backupcopy=
setlocal balloonexpr=xolox#lua#getsignature(v:beval_text)
setlocal nobinary
setlocal nobreakindent
setlocal breakindentopt=
setlocal bufhidden=
setlocal buflisted
setlocal buftype=
setlocal nocindent
setlocal cinkeys=0{,0},0),0],:,0#,!^F,o,O,e
setlocal cinoptions=
setlocal cinwords=if,else,while,do,for,switch
setlocal colorcolumn=
setlocal comments=s:--[[,m:\ ,e:]],:--
setlocal commentstring=--%s
setlocal complete=.,w,b,u,t,i
setlocal concealcursor=
setlocal conceallevel=0
setlocal completefunc=xolox#lua#completefunc
setlocal completeslash=
setlocal nocopyindent
setlocal cryptmethod=
setlocal nocursorbind
setlocal nocursorcolumn
set cursorline
setlocal cursorline
setlocal cursorlineopt=both
setlocal define=
setlocal dictionary=
setlocal nodiff
setlocal equalprg=
setlocal errorformat=
setlocal expandtab
if &filetype != 'lua'
setlocal filetype=lua
endif
setlocal fixendofline
setlocal foldcolumn=0
setlocal foldenable
setlocal foldexpr=0
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldmarker={{{,}}}
setlocal foldmethod=manual
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal foldtext=foldtext()
setlocal formatexpr=
setlocal formatoptions=croql
setlocal formatlistpat=^\\s*\\d\\+[\\]:.)}\\t\ ]\\s*
setlocal formatprg=
setlocal grepprg=
setlocal iminsert=0
setlocal imsearch=-1
setlocal include=\\v<((do|load)file|require)[^'\"]*['\"]\\zs[^'\"]+
setlocal includeexpr=xolox#lua#includeexpr(v:fname)
setlocal indentexpr=GetLuaIndent()
setlocal indentkeys=0{,0},0),0],:,0#,!^F,o,O,e,0=end,0=until,0=elseif,0=else
setlocal noinfercase
setlocal iskeyword=@,48-57,_,192-255
setlocal keywordprg=
setlocal nolinebreak
setlocal nolisp
setlocal lispwords=
set list
setlocal list
setlocal makeencoding=
setlocal makeprg=
setlocal matchpairs=(:),{:},[:]
setlocal modeline
setlocal modifiable
setlocal nrformats=bin,octal,hex
setlocal nonumber
setlocal numberwidth=4
setlocal omnifunc=xolox#lua#omnifunc
setlocal path=
setlocal nopreserveindent
setlocal nopreviewwindow
setlocal quoteescape=\\
setlocal noreadonly
set relativenumber
setlocal relativenumber
setlocal norightleft
setlocal rightleftcmd=search
setlocal noscrollbind
setlocal scrolloff=-1
setlocal shiftwidth=2
setlocal noshortname
setlocal showbreak=
setlocal sidescrolloff=-1
setlocal signcolumn=auto
setlocal nosmartindent
setlocal softtabstop=2
setlocal nospell
setlocal spellcapcheck=[.?!]\\_[\\])'\"\	\ ]\\+
setlocal spellfile=
setlocal spelllang=en
setlocal statusline=
setlocal suffixesadd=
setlocal swapfile
setlocal synmaxcol=3000
if &syntax != 'lua'
setlocal syntax=lua
endif
setlocal tabstop=2
setlocal tagcase=
setlocal tagfunc=
setlocal tags=
setlocal termwinkey=
setlocal termwinscroll=10000
setlocal termwinsize=
setlocal textwidth=0
setlocal thesaurus=
setlocal noundofile
setlocal undolevels=-123456
setlocal varsofttabstop=
setlocal vartabstop=
setlocal wincolor=
setlocal nowinfixheight
setlocal nowinfixwidth
setlocal wrap
setlocal wrapmargin=0
silent! normal! zE
let s:l = 4 - ((1 * winheight(0) + 14) / 29)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
4
normal! 031|
wincmd w
argglobal
if bufexists("C:\Data\Roblox\Places\PetShopPanic\src\ReplicatedStorage\Avatars.lua") | buffer C:\Data\Roblox\Places\PetShopPanic\src\ReplicatedStorage\Avatars.lua | else | edit C:\Data\Roblox\Places\PetShopPanic\src\ReplicatedStorage\Avatars.lua | endif
let s:cpo_save=&cpo
set cpo&vim
imap <buffer> <F1> :call xolox#lua#help()
nmap <buffer> K :call xolox#lua#help()
noremap <buffer> <silent> [] m':call xolox#lua#jumpotherfunc(0)
noremap <buffer> <silent> [[ m':call xolox#lua#jumpthisfunc(0)
noremap <buffer> <silent> [{ m':call xolox#lua#jumpblock(0)
noremap <buffer> <silent> ]] m':call xolox#lua#jumpotherfunc(1)
noremap <buffer> <silent> ][ m':call xolox#lua#jumpthisfunc(1)
noremap <buffer> <silent> ]} m':call xolox#lua#jumpblock(1)
nmap <buffer> <F1> :call xolox#lua#help()
inoremap <buffer> <silent> <expr> " xolox#lua#completedynamic('"')
inoremap <buffer> <silent> <expr> ' xolox#lua#completedynamic("'")
inoremap <buffer> <silent> <expr> . xolox#lua#completedynamic('.')
let &cpo=s:cpo_save
unlet s:cpo_save
setlocal keymap=
setlocal noarabic
setlocal autoindent
setlocal backupcopy=
setlocal balloonexpr=xolox#lua#getsignature(v:beval_text)
setlocal nobinary
setlocal nobreakindent
setlocal breakindentopt=
setlocal bufhidden=
setlocal buflisted
setlocal buftype=
setlocal nocindent
setlocal cinkeys=0{,0},0),0],:,0#,!^F,o,O,e
setlocal cinoptions=
setlocal cinwords=if,else,while,do,for,switch
setlocal colorcolumn=
setlocal comments=s:--[[,m:\ ,e:]],:--
setlocal commentstring=--%s
setlocal complete=.,w,b,u,t,i
setlocal concealcursor=
setlocal conceallevel=0
setlocal completefunc=xolox#lua#completefunc
setlocal completeslash=
setlocal nocopyindent
setlocal cryptmethod=
setlocal nocursorbind
setlocal nocursorcolumn
set cursorline
setlocal cursorline
setlocal cursorlineopt=both
setlocal define=
setlocal dictionary=
setlocal nodiff
setlocal equalprg=
setlocal errorformat=
setlocal expandtab
if &filetype != 'lua'
setlocal filetype=lua
endif
setlocal fixendofline
setlocal foldcolumn=0
setlocal foldenable
setlocal foldexpr=0
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldmarker={{{,}}}
setlocal foldmethod=manual
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal foldtext=foldtext()
setlocal formatexpr=
setlocal formatoptions=croql
setlocal formatlistpat=^\\s*\\d\\+[\\]:.)}\\t\ ]\\s*
setlocal formatprg=
setlocal grepprg=
setlocal iminsert=0
setlocal imsearch=-1
setlocal include=\\v<((do|load)file|require)[^'\"]*['\"]\\zs[^'\"]+
setlocal includeexpr=xolox#lua#includeexpr(v:fname)
setlocal indentexpr=GetLuaIndent()
setlocal indentkeys=0{,0},0),0],:,0#,!^F,o,O,e,0=end,0=until,0=elseif,0=else
setlocal noinfercase
setlocal iskeyword=@,48-57,_,192-255
setlocal keywordprg=
setlocal nolinebreak
setlocal nolisp
setlocal lispwords=
set list
setlocal list
setlocal makeencoding=
setlocal makeprg=
setlocal matchpairs=(:),{:},[:]
setlocal modeline
setlocal modifiable
setlocal nrformats=bin,octal,hex
setlocal nonumber
setlocal numberwidth=4
setlocal omnifunc=xolox#lua#omnifunc
setlocal path=
setlocal nopreserveindent
setlocal nopreviewwindow
setlocal quoteescape=\\
setlocal noreadonly
set relativenumber
setlocal relativenumber
setlocal norightleft
setlocal rightleftcmd=search
setlocal noscrollbind
setlocal scrolloff=-1
setlocal shiftwidth=2
setlocal noshortname
setlocal showbreak=
setlocal sidescrolloff=-1
setlocal signcolumn=auto
setlocal nosmartindent
setlocal softtabstop=2
setlocal nospell
setlocal spellcapcheck=[.?!]\\_[\\])'\"\	\ ]\\+
setlocal spellfile=
setlocal spelllang=en
setlocal statusline=
setlocal suffixesadd=
setlocal swapfile
setlocal synmaxcol=3000
if &syntax != 'lua'
setlocal syntax=lua
endif
setlocal tabstop=2
setlocal tagcase=
setlocal tagfunc=
setlocal tags=
setlocal termwinkey=
setlocal termwinscroll=10000
setlocal termwinsize=
setlocal textwidth=0
setlocal thesaurus=
setlocal noundofile
setlocal undolevels=-123456
setlocal varsofttabstop=
setlocal vartabstop=
setlocal wincolor=
setlocal nowinfixheight
setlocal nowinfixwidth
setlocal wrap
setlocal wrapmargin=0
silent! normal! zE
let s:l = 10 - ((9 * winheight(0) + 14) / 28)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
10
normal! 031|
wincmd w
exe 'vert 1resize ' . ((&columns * 134 + 134) / 269)
exe '2resize ' . ((&lines * 29 + 30) / 61)
exe 'vert 2resize ' . ((&columns * 134 + 134) / 269)
exe '3resize ' . ((&lines * 28 + 30) / 61)
exe 'vert 3resize ' . ((&columns * 134 + 134) / 269)
tabnext
edit C:\Data\Roblox\Places\PetShopPanic\src\ServerScriptService\SelectCharacter.server.lua
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd w
set nosplitbelow
set nosplitright
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe 'vert 1resize ' . ((&columns * 134 + 134) / 269)
exe 'vert 2resize ' . ((&columns * 134 + 134) / 269)
argglobal
let s:cpo_save=&cpo
set cpo&vim
imap <buffer> <F1> :call xolox#lua#help()
nmap <buffer> K :call xolox#lua#help()
noremap <buffer> <silent> [] m':call xolox#lua#jumpotherfunc(0)
noremap <buffer> <silent> [[ m':call xolox#lua#jumpthisfunc(0)
noremap <buffer> <silent> [{ m':call xolox#lua#jumpblock(0)
noremap <buffer> <silent> ]] m':call xolox#lua#jumpotherfunc(1)
noremap <buffer> <silent> ][ m':call xolox#lua#jumpthisfunc(1)
noremap <buffer> <silent> ]} m':call xolox#lua#jumpblock(1)
nmap <buffer> <F1> :call xolox#lua#help()
inoremap <buffer> <silent> <expr> " xolox#lua#completedynamic('"')
inoremap <buffer> <silent> <expr> ' xolox#lua#completedynamic("'")
inoremap <buffer> <silent> <expr> . xolox#lua#completedynamic('.')
let &cpo=s:cpo_save
unlet s:cpo_save
setlocal keymap=
setlocal noarabic
setlocal autoindent
setlocal backupcopy=
setlocal balloonexpr=xolox#lua#getsignature(v:beval_text)
setlocal nobinary
setlocal nobreakindent
setlocal breakindentopt=
setlocal bufhidden=
setlocal buflisted
setlocal buftype=
setlocal nocindent
setlocal cinkeys=0{,0},0),0],:,0#,!^F,o,O,e
setlocal cinoptions=
setlocal cinwords=if,else,while,do,for,switch
setlocal colorcolumn=
setlocal comments=s:--[[,m:\ ,e:]],:--
setlocal commentstring=--%s
setlocal complete=.,w,b,u,t,i
setlocal concealcursor=
setlocal conceallevel=0
setlocal completefunc=xolox#lua#completefunc
setlocal completeslash=
setlocal nocopyindent
setlocal cryptmethod=
setlocal nocursorbind
setlocal nocursorcolumn
set cursorline
setlocal cursorline
setlocal cursorlineopt=both
setlocal define=
setlocal dictionary=
setlocal nodiff
setlocal equalprg=
setlocal errorformat=
setlocal expandtab
if &filetype != 'lua'
setlocal filetype=lua
endif
setlocal fixendofline
setlocal foldcolumn=0
setlocal foldenable
setlocal foldexpr=0
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldmarker={{{,}}}
setlocal foldmethod=manual
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal foldtext=foldtext()
setlocal formatexpr=
setlocal formatoptions=croql
setlocal formatlistpat=^\\s*\\d\\+[\\]:.)}\\t\ ]\\s*
setlocal formatprg=
setlocal grepprg=
setlocal iminsert=0
setlocal imsearch=-1
setlocal include=\\v<((do|load)file|require)[^'\"]*['\"]\\zs[^'\"]+
setlocal includeexpr=xolox#lua#includeexpr(v:fname)
setlocal indentexpr=GetLuaIndent()
setlocal indentkeys=0{,0},0),0],:,0#,!^F,o,O,e,0=end,0=until,0=elseif,0=else
setlocal noinfercase
setlocal iskeyword=@,48-57,_,192-255
setlocal keywordprg=
setlocal nolinebreak
setlocal nolisp
setlocal lispwords=
set list
setlocal list
setlocal makeencoding=
setlocal makeprg=
setlocal matchpairs=(:),{:},[:]
setlocal modeline
setlocal modifiable
setlocal nrformats=bin,octal,hex
setlocal nonumber
setlocal numberwidth=4
setlocal omnifunc=xolox#lua#omnifunc
setlocal path=
setlocal nopreserveindent
setlocal nopreviewwindow
setlocal quoteescape=\\
setlocal noreadonly
set relativenumber
setlocal relativenumber
setlocal norightleft
setlocal rightleftcmd=search
setlocal noscrollbind
setlocal scrolloff=-1
setlocal shiftwidth=2
setlocal noshortname
setlocal showbreak=
setlocal sidescrolloff=-1
setlocal signcolumn=auto
setlocal nosmartindent
setlocal softtabstop=2
setlocal nospell
setlocal spellcapcheck=[.?!]\\_[\\])'\"\	\ ]\\+
setlocal spellfile=
setlocal spelllang=en
setlocal statusline=
setlocal suffixesadd=
setlocal swapfile
setlocal synmaxcol=3000
if &syntax != 'lua'
setlocal syntax=lua
endif
setlocal tabstop=2
setlocal tagcase=
setlocal tagfunc=
setlocal tags=
setlocal termwinkey=
setlocal termwinscroll=10000
setlocal termwinsize=
setlocal textwidth=0
setlocal thesaurus=
setlocal noundofile
setlocal undolevels=-123456
setlocal varsofttabstop=
setlocal vartabstop=
setlocal wincolor=
setlocal nowinfixheight
setlocal nowinfixwidth
setlocal wrap
setlocal wrapmargin=0
silent! normal! zE
let s:l = 103 - ((31 * winheight(0) + 29) / 58)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
103
normal! 013|
lcd C:\Data\Roblox\Places\PetShopPanic\src\StarterGui
wincmd w
argglobal
if bufexists("C:\Data\Roblox\Places\PetShopPanic\src\StarterGui\AvatarGui.lua") | buffer C:\Data\Roblox\Places\PetShopPanic\src\StarterGui\AvatarGui.lua | else | edit C:\Data\Roblox\Places\PetShopPanic\src\StarterGui\AvatarGui.lua | endif
let s:cpo_save=&cpo
set cpo&vim
imap <buffer> <F1> :call xolox#lua#help()
nmap <buffer> K :call xolox#lua#help()
noremap <buffer> <silent> [] m':call xolox#lua#jumpotherfunc(0)
noremap <buffer> <silent> [[ m':call xolox#lua#jumpthisfunc(0)
noremap <buffer> <silent> [{ m':call xolox#lua#jumpblock(0)
noremap <buffer> <silent> ]] m':call xolox#lua#jumpotherfunc(1)
noremap <buffer> <silent> ][ m':call xolox#lua#jumpthisfunc(1)
noremap <buffer> <silent> ]} m':call xolox#lua#jumpblock(1)
nmap <buffer> <F1> :call xolox#lua#help()
inoremap <buffer> <silent> <expr> " xolox#lua#completedynamic('"')
inoremap <buffer> <silent> <expr> ' xolox#lua#completedynamic("'")
inoremap <buffer> <silent> <expr> . xolox#lua#completedynamic('.')
let &cpo=s:cpo_save
unlet s:cpo_save
setlocal keymap=
setlocal noarabic
setlocal autoindent
setlocal backupcopy=
setlocal balloonexpr=xolox#lua#getsignature(v:beval_text)
setlocal nobinary
setlocal nobreakindent
setlocal breakindentopt=
setlocal bufhidden=
setlocal buflisted
setlocal buftype=
setlocal nocindent
setlocal cinkeys=0{,0},0),0],:,0#,!^F,o,O,e
setlocal cinoptions=
setlocal cinwords=if,else,while,do,for,switch
setlocal colorcolumn=
setlocal comments=s:--[[,m:\ ,e:]],:--
setlocal commentstring=--%s
setlocal complete=.,w,b,u,t,i
setlocal concealcursor=
setlocal conceallevel=0
setlocal completefunc=xolox#lua#completefunc
setlocal completeslash=
setlocal nocopyindent
setlocal cryptmethod=
setlocal nocursorbind
setlocal nocursorcolumn
set cursorline
setlocal cursorline
setlocal cursorlineopt=both
setlocal define=
setlocal dictionary=
setlocal nodiff
setlocal equalprg=
setlocal errorformat=
setlocal expandtab
if &filetype != 'lua'
setlocal filetype=lua
endif
setlocal fixendofline
setlocal foldcolumn=0
setlocal foldenable
setlocal foldexpr=0
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldmarker={{{,}}}
setlocal foldmethod=manual
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal foldtext=foldtext()
setlocal formatexpr=
setlocal formatoptions=croql
setlocal formatlistpat=^\\s*\\d\\+[\\]:.)}\\t\ ]\\s*
setlocal formatprg=
setlocal grepprg=
setlocal iminsert=0
setlocal imsearch=-1
setlocal include=\\v<((do|load)file|require)[^'\"]*['\"]\\zs[^'\"]+
setlocal includeexpr=xolox#lua#includeexpr(v:fname)
setlocal indentexpr=GetLuaIndent()
setlocal indentkeys=0{,0},0),0],:,0#,!^F,o,O,e,0=end,0=until,0=elseif,0=else
setlocal noinfercase
setlocal iskeyword=@,48-57,_,192-255
setlocal keywordprg=
setlocal nolinebreak
setlocal nolisp
setlocal lispwords=
set list
setlocal list
setlocal makeencoding=
setlocal makeprg=
setlocal matchpairs=(:),{:},[:]
setlocal modeline
setlocal modifiable
setlocal nrformats=bin,octal,hex
setlocal nonumber
setlocal numberwidth=4
setlocal omnifunc=xolox#lua#omnifunc
setlocal path=
setlocal nopreserveindent
setlocal nopreviewwindow
setlocal quoteescape=\\
setlocal noreadonly
set relativenumber
setlocal relativenumber
setlocal norightleft
setlocal rightleftcmd=search
setlocal noscrollbind
setlocal scrolloff=-1
setlocal shiftwidth=2
setlocal noshortname
setlocal showbreak=
setlocal sidescrolloff=-1
setlocal signcolumn=auto
setlocal nosmartindent
setlocal softtabstop=2
setlocal nospell
setlocal spellcapcheck=[.?!]\\_[\\])'\"\	\ ]\\+
setlocal spellfile=
setlocal spelllang=en
setlocal statusline=
setlocal suffixesadd=
setlocal swapfile
setlocal synmaxcol=3000
if &syntax != 'lua'
setlocal syntax=lua
endif
setlocal tabstop=2
setlocal tagcase=
setlocal tagfunc=
setlocal tags=
setlocal termwinkey=
setlocal termwinscroll=10000
setlocal termwinsize=
setlocal textwidth=0
setlocal thesaurus=
setlocal noundofile
setlocal undolevels=-123456
setlocal varsofttabstop=
setlocal vartabstop=
setlocal wincolor=
setlocal nowinfixheight
setlocal nowinfixwidth
setlocal wrap
setlocal wrapmargin=0
silent! normal! zE
let s:l = 153 - ((0 * winheight(0) + 29) / 58)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
153
normal! 01|
lcd C:\Data\Roblox\Places\PetShopPanic\src\StarterGui
wincmd w
exe 'vert 1resize ' . ((&columns * 134 + 134) / 269)
exe 'vert 2resize ' . ((&columns * 134 + 134) / 269)
tabnext 1
badd +1 C:\Data\Roblox\Places\PetShopPanic\default.project.json
badd +61 C:\Data\Roblox\Places\PetShopPanic\src\ServerScriptService\BuyDeveloperProduct.server.lua
badd +24 C:\Data\Roblox\Places\PetShopPanic\src\ServerScriptService\DatabaseAdapter.lua
badd +1 C:\Data\Roblox\Places\PetShopPanic\src\ServerScriptService\SelectCharacter.server.lua
badd +24 C:\Data\Roblox\Places\PetShopPanic\src\ReplicatedStorage\Session.lua
badd +99 C:\Data\Roblox\Places\PetShopPanic\src\ServerScriptService\PlayerManager.lua
badd +4 C:\Data\Roblox\Places\PetShopPanic\src\ReplicatedStorage\Globals.lua
badd +1 C:\Data\Roblox\Places\PetShopPanic\src\ReplicatedStorage\Avatars.lua
badd +37 C:\Data\Roblox\Places\PetShopPanic\src\ServerScriptService\Cmd.lua
badd +179 C:\Data\Roblox\Places\PetShopPanic\src\StarterGui\AvatarGui.lua
badd +15 C:\Data\Roblox\Places\PetShopPanic\src\ReplicatedStorage\Gui\ViewportFrameFactory.lua
badd +46 C:\Data\Roblox\Places\PetShopPanic\src\StarterGui\PlayGui.lua
badd +320 C:\Data\Roblox\Places\PetShopPanic\src\StarterGui\ScoreGui.lua
badd +85 C:\Data\Roblox\Places\PetShopPanic\src\ServerScriptService\Game.server.lua
badd +191 C:\Data\Roblox\Places\PetShopPanic\src\StarterGui\LobbyGui.client.lua
badd +90 C:\Data\Roblox\Places\PetShopPanic\src\StarterGui\AnnouncementGui.client.lua
badd +17 C:\Data\Roblox\Places\PetShopPanic\src\StarterGui\UserThumbnailGui.lua
badd +27 C:\Data\Roblox\Places\PetShopPanic\src\ServerScriptService\InitializePlayer.server.lua
badd +3 C:\Data\Roblox\Places\PetShopPanic\src\ReplicatedStorage\Consumers\Consumer.lua
badd +1 C:\Data\Roblox\Places\PetShopPanic\src\StarterPlayer\StarterPlayerScripts\InitializePlayer.client.lua
badd +46 C:\Data\Roblox\Places\PetShopPanic\src\ReplicatedStorage\Util.lua
badd +8 C:\Data\Roblox\Places\PetShopPanic\src\ReplicatedStorage\Products\Product.lua
badd +1 C:\Data\Roblox\Places\PetShopPanic\src\ReplicatedStorage\AnimationModule.lua
badd +24 C:\Data\Roblox\Places\PetShopPanic\src\StarterPlayer\StarterCharacterScripts\InitializeCharacter.client.lua
badd +1 C:\Data\Roblox\Places\PetShopPanic\src\ReplicatedStorage\Products\ProductFactory.lua
badd +1 C:\Data\Roblox\Places\PetShopPanic\src\ServerScriptService\MapManager.lua
badd +1 C:\Data\Roblox\Places\PetShopPanic\src\ReplicatedStorage\Gui\ParticleEmitterFactory.lua
badd +105 C:\Data\Roblox\Places\PetShopPanic\src\ReplicatedStorage\Gui\TweenGuiFactory.lua
badd +6 C:\Data\Roblox\Places\PetShopPanic\src\ReplicatedStorage\SoundModule.lua
badd +20 C:\Data\Roblox\Places\PetShopPanic\src\ReplicatedStorage\Themes.lua
badd +1 C:\Data\Roblox\Places\PetShopPanic\src\ReplicatedStorage\TrashBins\TrashBin.lua
badd +124 C:\Data\Roblox\Places\PetShopPanic\src\ReplicatedStorage\Factories\Factory.lua
badd +1 C:\Data\Roblox\Places\PetShopPanic\src\ReplicatedStorage\Gui\ProximityPromptFactory.lua
badd +1 C:\Data\Roblox\Places\PetShopPanic\src\ReplicatedStorage\Factories\FactoryFactory.lua
badd +1 C:\Data\Roblox\Places\PetShopPanic\src\ReplicatedStorage\Consumers\DefaultConsumer.lua
badd +1 C:\Data\Roblox\Places\PetShopPanic\src\ReplicatedStorage\Consumers\ConsumerFactory.lua
badd +159 C:\Data\Roblox\Places\PetShopPanic\src\ReplicatedStorage\Transformers\Transformer.lua
badd +1 C:\Data\Roblox\Places\PetShopPanic\src\ReplicatedStorage\Transformers\DefaultTransformer.lua
badd +1 C:\Data\Roblox\Places\PetShopPanic\src\ReplicatedStorage\Factories\DefaultFactory.lua
badd +1 C:\Data\Roblox\Places\PetShopPanic\src\ReplicatedStorage\Transformers\TransformerFactory.lua
badd +1 C:\Data\Roblox\Places\PetShopPanic\src\ReplicatedStorage\Gui\ProgressBarFactory.lua
badd +1 C:\Data\Roblox\Places\PetShopPanic\src\ReplicatedStorage\Settings.lua
badd +1 C:\Data\Roblox\Places\PetShopPanic\src\ReplicatedStorage\Gui\RadialBackgroundFactory.lua
badd +1 C:\Data\Roblox\Places\PetShopPanic\src\ReplicatedStorage\Gui\DecalFactory.lua
badd +1 C:\Data\Roblox\Places\PetShopPanic\src\StarterGui
badd +118 C:\Data\Roblox\Places\PetShopPanic\src\StarterGui\SessionGui.client.lua
badd +2 C:\Data\Roblox\Places\PetShopPanic\src\ReplicatedStorage\Events\SelectLevelRequestSent.model.json
badd +767 C:\Data\Roblox\Places\PetShopPanic\session.vim
badd +20 C:\Data\Roblox\Places\PetShopPanic\src\StarterGui\PlayerCamera.client.lua
badd +94 C:\Data\Roblox\Places\PetShopPanic\src\StarterPlayer\StarterCharacterScripts\SelectCharacter.client.lua
badd +6 C:\Data\Roblox\Places\PetShopPanic\src\StarterPlayer\StarterPlayerScripts\MusicManager.client.lua
badd +17 C:\Data\Roblox\Places\PetShopPanic\src\StarterGui\FrameFactory.lua
badd +2 C:\Data\Roblox\Places\PetShopPanic\src\ReplicatedStorage\RemoteFunctions\GetSessionStatus.model.json
if exists('s:wipebuf') && len(win_findbuf(s:wipebuf)) == 0
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20 shortmess=filnxtToOS
set winminheight=1 winminwidth=1
let s:sx = expand("<sfile>:p:r")."x.vim"
if file_readable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &so = s:so_save | let &siso = s:siso_save
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
