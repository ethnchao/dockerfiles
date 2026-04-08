#!/bin/sh
# 写入 vim 全局初始化配置，提升使用体验

set -e

cat > /etc/vim/vimrc.local <<'EOF'
" ── 基础显示 ──────────────────────────────
set number              " 显示行号
set relativenumber      " 相对行号，方便跳转
set cursorline          " 高亮当前行
set showmatch           " 高亮匹配括号
set ruler               " 右下角显示光标位置
set laststatus=2        " 始终显示状态栏
set title               " 终端标题显示文件名
syntax on               " 语法高亮

" ── 缩进 ──────────────────────────────────
set tabstop=4           " Tab 宽度 4 空格
set shiftwidth=4        " 自动缩进 4 空格
set expandtab           " Tab 转为空格
set autoindent          " 自动缩进
set smartindent         " 智能缩进

" ── 搜索 ──────────────────────────────────
set hlsearch            " 高亮搜索结果
set incsearch           " 实时搜索
set ignorecase          " 搜索忽略大小写
set smartcase           " 有大写时恢复大小写敏感

" ── 编码 ──────────────────────────────────
set encoding=utf-8
set fileencoding=utf-8

" ── 交互体验 ──────────────────────────────
set backspace=indent,eol,start  " 退格键正常工作
set mouse=a                     " 启用鼠标
set clipboard=unnamed           " 与系统剪贴板共享
set scrolloff=5                 " 光标距边缘保留 5 行
set wildmenu                    " 命令补全菜单
set pastetoggle=<F2>            " F2 切换粘贴模式

" ── 空白字符可视化 ────────────────────────
set list
set listchars=tab:▸\ ,trail:·

" ── 快捷键 ────────────────────────────────
" <leader> 设为空格
let mapleader=" "
" Ctrl+S 保存
nnoremap <C-s> :w<CR>
inoremap <C-s> <Esc>:w<CR>a
" 取消搜索高亮
nnoremap <leader>/ :nohlsearch<CR>
EOF

# 同时写入 root 的 .vimrc 作为备用
cp /etc/vim/vimrc.local /root/.vimrc

echo "[setup-vim] vim 配置已写入 /etc/vim/vimrc.local 和 /root/.vimrc"
