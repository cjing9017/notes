let mapleader=" "
" 开启文件类型检测，包括自动缩进及设置
filetype plugin indent on

" utf-8编码
set encoding=UTF-8

" 取消vi兼容
set nocompatible

" 首位为0的数字不被处理为八进制数字
set nrformats-=octal

" 分割窗口的分割竖线
set fillchars=vert:\|
" 分割窗口的分割线样式
highlight VertSplit cterm=none gui=none

" 高亮显示所有搜索匹配的地方
set hlsearch
" 文件保存写入时，取消高亮
exec "nohlsearch"
" 在输入字符串的过程中高亮显示匹配的地方
set incsearch
" 查找到文件尾会自动折返到文件头
set wrapscan
" 忽略大小写
set ignorecase
" 智能匹配大小写
set smartcase

" 光标上下两侧最少保留的屏幕行数
set scrolloff=25

" 字符配对
set mps+=<:>
" 高亮显示匹配的字符
set showmatch
" 高亮显示匹配的字符时长1秒
set matchtime=10

" 色彩高亮
syntax on

" 行号
set number
" 相对行号
set relativenumber
" 显示光标行
set cursorline

" 将缩进作为折叠方式
set foldmethod=indent
" 打开文件默认不折叠
set foldlevelstart=99
" 在窗口左侧显示一小栏标识各个折叠
" set foldcolumn=2

" Tab键显示4个空格长度
set tabstop=4
" Tab键在编辑模式下4个空格宽度值的缩进量
set softtabstop=4
" 每一级缩进的长度为4个空格
set shiftwidth=4
" 用制表符表示一个缩进
set expandtab
" 开始一个新行时，新行会采用和上一行相同的缩进
set autoindent


" 窗口右下角显示当前光标的位置
set ruler
" 底部显示当前所处的模式
set showmode
" 窗口右下角显示未完成的命令
set showcmd

" 保存200个命令和查找模式的历史
set history=200

" 在状态行上显示补全匹配
set wildmenu
" 指定字符补全模式
set wildmode=full
" 补全忽略大小写
set wildignorecase

" 避免破坏映射
set nolangremap

" 禁止长行自动回绕
set nowrap
" 移动到长行不显示的文字时，向右滚动10个字符
set sidescroll=10

" 当光标处于行首，使用<BS>键可以回到前一行的结尾
" 当光标处于行尾，使用<Space>键可以移动到下一行的行首
" 支持插入模式和普通模式中的<Left>和<Right>也能使用
set whichwrap=b,s,<,>,[,]

" 显示TAB键的空白字符
set list
" TAB被显示成">---"，行尾多余的空白字符显示成"-"
set listchars=tab:>-,trail:-

" 自动保存文件
set autowrite
" 备份文件，覆盖文件后删除备份文件
set writebackup
" 备份文件的扩展名
set backupext=.bak
" 保留原始文件
" set patchmode=.orig

" 1000: 为1000个文件（a-z）保存标记
" f1: 存储全局标记（A-Z和0-9）
" <500: 每个寄存器内保存500行文本
" :500: 保存500行命令行历史记录内的行数
" @500: 保存500行输入行历史记录内的行数
" /500: 保存500行搜索历史记录内的行数
set viminfo='1000,f1,<500,:500,@500,/500

" 设置处理表格时的虚拟空间
" set virtualedit=all

" ======================================== COMMAND命令映射 ========================================

" ======================================== NORMAL按键映射 ========================================
" 映射文件保存
map S :w<CR>
map R :source $MYVIMRC<CR>

" 映射窗水平分割
noremap ss :split<CR>
" 映射窗口垂直分割
noremap sv :vsplit<CR>

" 映射分割的窗口间移动
noremap <LEADER>j <C-W>j
noremap <LEADER>k <C-W>k
noremap <LEADER>h <C-W>h
noremap <LEADER>l <C-W>l

" 映射移动分割的窗口
noremap <LEADER>J <C-W>J
noremap <LEADER>K <C-W>K
noremap <LEADER>H <C-W>H
noremap <LEADER>L <C-W>L

" 映射调整分割窗口高度
noremap <up> :res+5<CR>
noremap <down> :res-5<CR>
" 映射调整分割窗口宽度
noremap <left> :vertical resize-5<CR>
noremap <right> :vertical resize+5<CR>

" 映射取消搜索词高亮
noremap <LEADER><CR> :nohlsearch<CR>

" 映射新建标签页
noremap te :tabedit<CR>
" 映射标签页间移动
noremap tl :+tabnext<CR>
noremap th :-tabnext<CR>

" 映射复制全部内容
nnoremap <LEADER>a ggVG"+y

" ----------------------------------------          nerdtree NORMAL按键映射
" 映射nerdtree窗口显示与关闭
" noremap nt :NERDTreeToggle<CR>

" ----------------------------------------          tagbar NORMAL按键映射
" 映射tagbar窗口显示与关闭
noremap tt :TagbarToggle<CR>

" ----------------------------------------          vim-quickui NORMAL按键映射
" 映射打开python3环境窗口
nnoremap <LEADER>p :call quickui#terminal#open('python3', terminal_opts)<CR>
" 映射打开顶部菜单栏窗口
nnoremap <LEADER>m :call quickui#menu#open()<CR>
" 映射打开文件预览窗口，文件名需要在单引号内
nnoremap <LEADER>f "fyi':call quickui#preview#open(fnamemodify('<C-R>f', ':p'), preview_opts)<CR>

" ----------------------------------------          markdown-preview NORMAL按键映射
" 映射打开/关闭Makrdown预览窗口
nmap <LEADER>d <Plug>MarkdownPreviewToggle

" ----------------------------------------          vim-pydocstring NORMAL按键映射
nmap <LEADER>pd <Plug>(pydocstring)

" ----------------------------------------          telescope NORMAL按键映射
" 映射查找文件
nnoremap <LEADER>ff <CMD>Telescope find_files<CR>
" 映射查找文件内容
nnoremap <LEADER>fg <CMD>Telescope live_grep<CR>

" ----------------------------------------          nvim-tree NORMAL按键映射
" 映射nvim-tree目录打开/关闭
nnoremap nt <CMD>NvimTreeToggle<CR>

" ----------------------------------------          vim-table-mode NORMAL按键映射
" 映射Table Mode模式的开启/关闭
nnoremap <LEADER>tm :TableModeToggle<CR>
" 映射Table Mode模式下删除表格的行

" ----------------------------------------          coc.vim NORMAL按键映射
" 自动修复当前行的问题
nmap <leader>qf  <Plug>(coc-fix-current)

" ======================================== INSERT按键映射 ========================================
" ----------------------------------------          coc.vim INSERT按键映射
" 映射TAB键用于补全
inoremap <silent><expr> <TAB>
  \ pumvisible() ? "\<C-n>" :
  \ <SID>check_back_space() ? "\<TAB>" :
  \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

" inoremap <silent><expr> <TAB>
"       \ pumvisible() ? coc#_select_confirm() :
"       \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
"       \ <SID>check_back_space() ? "\<TAB>" :
"       \ coc#refresh()

" TAB键无补全状态时，保持原作用
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:coc_snippet_next = '<tab>'

" 使用<CR>键时自动选择第一个补全项目
" inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
"                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" ======================================== VISUAL按键映射 ========================================
" ----------------------------------------          sniprun VISUAL按键映射
" 选中的代码片段运行
vmap <LEADER>sr <Plug>SnipRun

" ======================================== autocmd ========================================
" 打开文件时，移动到关闭文件时光标所在的位置
autocmd BufReadPost *
  \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
  \ |   exe "normal! g`\""
  \ | endif

" ----------------------------------------          *.sql file autocmd
" *.sql文件加载宏定义到指定寄存器
autocmd BufRead,BufNewFile *.sql
  \ let @a='0weld$j0' " ddl语句中提取字段

" ----------------------------------------          nerdtree autocmd
" 当剩下的最后一个窗口为nerdtree目录窗口时，退出vim
autocmd BufEnter *
  \ if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree()
  \ | quit
  \ | endif
" 每一个新打开的标签页保持nerdtree目录窗口不变
" autocmd BufWinEnter *
"   \ if getcmdwintype() == ''
"   \ | silent NERDTreeMirror
"   \ | endif

" ----------------------------------------          vim-pydocstring autocmd
" 设置.py类型文件的文档缩进
autocmd FileType python setlocal tabstop=4 shiftwidth=4 softtabstop=4 expandtab

" ----------------------------------------          nvim-tree autocmd
" 当目录窗口为最后一个窗口时，自动关闭
autocmd BufEnter * ++nested if winnr('$') == 1 && bufname() == 'NvimTree_' . tabpagenr() | quit | endif

" ======================================== 插件安装 ========================================
call plug#begin('$HOME/.config/nvim/plugged')

" vim文档
Plug 'yianwillis/vimcdoc'
" 可视化缩进
Plug 'Yggdroot/indentLine'
" 底部状态栏
Plug 'vim-airline/vim-airline'
" vim-airline的主题
Plug 'vim-airline/vim-airline-themes'
" 文件类型图标
Plug 'ryanoasis/vim-devicons'
" 目录
Plug 'preservim/nerdtree'
" nerdtree上显示git记录
Plug 'Xuyuanp/nerdtree-git-plugin'
" 嵌套括号高亮
Plug 'luochen1990/rainbow'
" 右侧窗口展示当前文件中的函数
Plug 'majutsushi/tagbar'
" 代码提示
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" 弹出窗口
Plug 'skywind3000/vim-quickui'
" 主题
Plug 'connorholyday/vim-snazzy'
" Git插件
Plug 'tpope/vim-fugitive'
" 代码注释
Plug 'preservim/nerdcommenter'
" 自动括号匹配
Plug 'jiangmiao/auto-pairs'
" 多光标
Plug 'terryma/vim-multiple-cursors'
" 启动页
Plug 'mhinz/vim-startify'
" MarkDown实时预览插件
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
" Python文档注释
Plug 'heavenshell/vim-pydocstring', { 'do': 'make install', 'for': 'python' }
" 代码片段运行
Plug 'michaelb/sniprun', {'do': 'bash install.sh'}
" 代码格式化
Plug 'sbdchd/neoformat'
" 文件搜索、过滤、预览
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
" 目录+支持目录的图标
Plug 'kyazdani42/nvim-web-devicons'
Plug 'kyazdani42/nvim-tree.lua'
" 绘制表格
Plug 'dhruvasagar/vim-table-mode'
" csv
Plug 'chrisbra/csv.vim'

call plug#end()

" ======================================== indentLine插件配置 ========================================
" 对齐线的尺寸
let g:indent_guides_guide_size = 1
" 缩进开始的层级
let g:indent_gudies_start_level = 2
" 对齐线显示的字符
let g:indentLine_char = '|'

" ======================================== vim-airline插件配置 ========================================
" 显示顶部标签栏
let g:airline#extensions#tabline#enabled = 1
" 顶部标签栏用竖线｜分割
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
" 顶部状态栏每个标签页的路径显示格式
let g:airline#extensions#tabline#formatter = 'default'

" 创建底部状态栏对象
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
" 定义当前文件状态标识
let g:airline_symbols.linenr = ' [CR] '
let g:airline_symbols.branch = ' [BR] '
let g:airline_symbols.readonly = ' [RO] '
let g:airline_symbols.dirty = ' [DT] '
let g:airline_symbols.crypt = ' [CR] '
" 定义行后符号
let g:airline_symbols.maxlinenr = ' ℅:'
" 定义列前符号
let g:airline_symbols.colnr = ''

" ======================================== vim-airline-themes插件配置 ========================================
" 设置vim-airline的主题
let g:airline_theme='desertink'

" ======================================== nerdtree插件配置 ========================================
" 设置未展开的目录前缀为符号+
let g:NERDTreeDirArrowExpandable = '+'
" 设置已展开的目录前缀为符号-
let g:NERDTreeDirArrowCollapsible = '-'
" 显示隐藏文件
let g:NERDTreeShowHidden = 1
" 显示行号
let g:NERDTreeShowLineNumbers = 1
" 隐藏首行的帮助提示
let g:NERDTreeMinimalUI = 0

" ======================================== nerdtree-git-plugin插件配置 ========================================
" 显示的字体
let g:NERDTreeGitStatusUseNerdFonts = 1
" 不同状态文件显示的前缀
let g:NERDTreeGitStatusIndicatorMapCustom = {
    \ 'Modified'  :'✹',
    \ 'Staged'    :'✚',
    \ 'Untracked' :'✭',
    \ 'Renamed'   :'➜',
    \ 'Unmerged'  :'═',
    \ 'Deleted'   :'✖',
    \ 'Dirty'     :'✗',
    \ 'Ignored'   :'☒',
    \ 'Clean'     :'✔︎',
    \ 'Unknown'   :'?',
    \ }

" ======================================== rainbow插件配置 ========================================
let g:rainbow_active = 0

" ======================================== tagbar插件配置 ========================================


" ======================================== coc.nvim插件配置 ========================================
let g:coc_global_extensions = [
    \ 'coc-tsserver',
    \ 'coc-sql',
    \ 'coc-sh',
    \ 'coc-pyright',
    \ 'coc-json',
    \ 'coc-java',
    \ 'coc-html',
    \ 'coc-css'
    \ ]

" ======================================== vim-quickui插件配置 ========================================
" 设置边框样式
let g:quickui_border_style = 1
" 设置颜色样式
let g:quickui_color_scheme='gruvbox'
" 设置窗口默认宽度
let g:quickui_preview_w = 85
" 设置窗口默认高度
let g:quickui_preview_h = 10

" ----------------------------------------          Terminal vim-quickui插件配置
" python3弹出窗口
function! TermExit(code)
    echom "terminal exit code: ". a:code
endfunc
let terminal_opts = {'w':60, 'h':8, 'callback':'TermExit'}
let terminal_opts.title = 'Python3 Terminal'

" ----------------------------------------          Menu vim-quickui插件配置
" 顶部菜单弹出窗口
call quickui#menu#reset()
call quickui#menu#install('&File', [
    \ ["&Write", ":write<CR>"],
    \ ["-"],
    \ ])
call quickui#menu#install('&Plugin', [
    \ ["\tNerdTree"],
    \ ["&NerdTree\tnt", "NERDTreeToggle"],
    \ ["-"],
    \ ["\tTagbar"],
    \ ["&Tagbar\ttt", "TagbarToggle"],
    \ ["-"],
    \ ["\tQuickUI"],
    \ ["&Terminal Window\tLeader+p", ""],
    \ ["-"],
    \ ["\tNerdCommenter"],
    \ ["&Comment\t[count]Leader+cc", ""],
    \ ["&UnComment\t[count]Leader+cu", ""],
    \ ["-"],
    \ ["\tAuto Pairs"],
    \ ["&Fast Wrap\t<M-e>", ""],
    \ ["&Move To Char\t<M-e>Char", ""],
    \ ["&Next Closed Pair\t<M-n>", ""],
    \ ["-"],
    \ ["\tMultiple Cursors"],
    \ ["&Select Word\t<C-n>", ""],
    \ ["&Skip Next Match\t<C-x>", ""],
    \ ["&Previous Match\t<C-p>", ""],
    \ ["&Select All Match\t<A-n>", ""],
    \ ["-"],
    \ ["\tMarkdown Preview"],
    \ ["&MarkdownPreviewToggle\tLeader+d", ""],
    \ ["-"],
    \ ["\tPydocstring"],
    \ ["&pydocstring\tLeader+pd", ""],
    \ ["-"],
    \ ["\tSnipRun"],
    \ ["&sniprun\tLeader+sr", ""],
    \ ["-"],
    \ ["\tTelescope"],
    \ ["&telescope find_files\tLeader+ff", ""],
    \ ["&telescope live_grep\tLeader+fg", ""],
    \ ["-"],
    \ ["\tVim Table Mode"],
    \ ["&Table Mode\tTableModeToggle", ""],
    \ ])

" 显示提示信息
let g:quickui_show_tip = 1

" ----------------------------------------          Preview vim-quickui插件配置
" 预览窗口大小
let preview_opts={'w':60, 'h':8, 'title':'File Preview'}

" ======================================== vim-fugitive插件配置 ========================================


" ======================================== nerdcommenter插件配置 ========================================
" 创建默认键位映射
let g:NERDCreateDefaultMappings = 1
" 在注释后添加1个空格
let g:NERDSpaceDelims = 1
" 使用紧凑型注释
let g:NERDCompactSexyComs = 1
" 多行注释左对齐
let g:NERDDefaultAlign = 'left'
" 取消注释时修建尾随空格
let g:NERDTrimTrailingWhitespace = 1

" ======================================== auto-pairs插件配置 ========================================
" 关闭Fly Mode
let g:AutoPairsFlyMode = 0

" ======================================== vim-multiple-cursors插件配置 ========================================
" 关闭默认映射
let g:multi_cursor_use_default_mapping = 0
" 按键映射
let g:multi_cursor_start_word_key      = '<C-n>'
let g:multi_cursor_select_all_word_key = '<A-n>'
let g:multi_cursor_start_key           = 'g<C-n>'
let g:multi_cursor_select_all_key      = 'g<A-n>'
let g:multi_cursor_next_key            = '<C-n>'
let g:multi_cursor_prev_key            = '<C-p>'
let g:multi_cursor_skip_key            = '<C-x>'
let g:multi_cursor_quit_key            = '<Esc>'

" ======================================== vim-startify插件配置 ========================================


" ======================================== vim-snazzy插件配置 ========================================
" 透明背景
let g:SnazzyTransparent = 0
" 设置颜色方案
colorscheme snazzy
" 设置亮线配色方案
let g:lightline = {
    \ 'colorscheme': 'snazzy',
    \ }

" ======================================== markdown-preview插件配置 ========================================
" 取消进入buffer后自动打开预览窗口
let g:mkdp_auto_start = 0
" 当切换buffer时自动关闭预览窗口
let g:mkdp_auto_close = 1
" 当编辑或者移动光标时自动刷新markdown
let g:mkdp_refresh_slow = 0
" MarkdownPreview命令仅可以使用在markdown类型文件中
let g:mkdp_command_for_global = 0
" 监听127.0.0.1
let g:mkdp_open_to_the_world = 0
" 预览窗口IP
let g:mkdp_open_ip = ''
" 打开预览窗口的默认浏览器
let g:mkdp_browser = ''
" 当打开预览页面时无需输入页面url
let g:mkdp_echo_preview_url = 0
" 自定义打开预览窗口的函数，并接受url作为参数
let g:mkdp_browserfunc = ''
" markdown render的配置
" mkit: markdown-it 配置
" katex: katex math配置
" uml: markdown-it-plantuml配置
" maid: mermaid配置
" disable_sync_scroll: 关闭同步滚动，默认为0
" sync_scroll_type: 同步滚动方式，默认是'middle'
"   middle: 光标在中间
"   top: 光标在顶部
"   relative:光标在底部
" hide_yaml_meta: 隐藏yaml元数据，默认为1
" sequence_diagrams: js-sequence-diagrams配置
" content_editable: 预览页面可编辑，默认为v:false
" disable_filename: 不显示文件名，默认为0
let g:mkdp_preview_options = {
    \ 'mkit': {},
    \ 'katex': {},
    \ 'uml': {},
    \ 'maid': {},
    \ 'disable_sync_scroll': 0,
    \ 'sync_scroll_type': 'middle',
    \ 'hide_yaml_meta': 1,
    \ 'sequence_diagrams': {},
    \ 'flowchart_diagrams': {},
    \ 'content_editable': v:false,
    \ 'disable_filename': 0
    \ }
" 使用自定义markdown style文件
let g:mkdp_markdown_css = ''
" 使用自定义高亮文件，必须使用绝对路径
" like '/Users/username/highlight.css' or expand('~/highlight.css')
let g:mkdp_highlight_css = ''
" 使用自定义端口
let g:mkdp_port = ''
" 定义预览窗口页面标题，使用文件名代替
let g:mkdp_page_title = '「${name}」'
" 识别文件类型
let g:mkdp_filetypes = ['markdown']

" ======================================== vim-pydocstring插件配置 ========================================
" 忽略__init__文档注释的生成
let g:pydocstring_ignore_init = 1
" 定义注释风格(Sphinx, Numpy, Google)
let g:pydocstring_formatter = 'Google'
" 设置注释模板
let g:pydocstring_templates_path = '/Users/chenjing/.config/nvim/template/pydocstring'

" ======================================== sniprun插件配置 ========================================


" ======================================== neoformat插件配置 ========================================
" 对json文件的格式化配置
let g:neoformat_json_jsonpp = {
      \ 'exe': "json_pp",
      \ 'args': ['-json_opt', 'utf8,pretty'],
      \ 'stdin': 1
      \ }
" 对json文件中中文的支持
let g:neoformat_enabled_json = ['jsonpp']

" ======================================== nvim-tree插件配置 ========================================
" 加载lua配置
lua require('plugin-config/nvim-tree')

" ======================================== vim-table-mode插件配置 ========================================
let g:table_mode_corner_cornet = '+'
let g:table_mode_header_fillchar = '-'
