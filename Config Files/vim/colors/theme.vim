" =========================================================
" theme.vim - Exacto a theme.lua, solo grupos compatibles
" =========================================================

set background=dark

" =====================================================
" UI Base (igual que Neovim)
" =====================================================
hi Normal         guifg=#f4dfd8 guibg=#090507
hi NormalNC       guifg=#dcc7c0 guibg=#090507
hi EndOfBuffer    guifg=#090507 guibg=#090507
hi LineNr         guifg=#5e2230 guibg=#090507
hi CursorLineNr   guifg=#fff6f3 guibg=#090507 gui=bold
hi CursorLine     guibg=#160b10
hi SignColumn     guibg=#090507
hi VertSplit      guifg=#5e2230 guibg=#090507

" Selección y búsqueda (igual)
hi Visual         guibg=#301721
hi Search         guifg=#090507 guibg=#f2a6b3 gui=bold
hi IncSearch      guifg=#090507 guibg=#ef4761 gui=bold

" Texto especial (igual)
hi Comment        guifg=#b79a95 gui=italic
hi NonText        guifg=#b79a95 guibg=#090507
hi SpecialKey     guifg=#f2a6b3 guibg=#301721 gui=bold

" Statusline y menús (igual)
hi StatusLine     guifg=#f4dfd8 guibg=#160b10 gui=bold
hi StatusLineNC   guifg=#b79a95 guibg=#090507
hi Pmenu          guifg=#f4dfd8 guibg=#211118
hi PmenuSel       guifg=#090507 guibg=#ef4761 gui=bold

" Tabline (igual)
hi TabLine        guifg=#f4dfd8 guibg=#160b10
hi TabLineSel     guifg=#090507 guibg=#ef4761 gui=bold
hi TabLineFill    guibg=#090507

" =====================================================
" Sintaxis (igual que apply_syntax)
" =====================================================
hi String         guifg=#f2a6b3
hi Character      guifg=#f2a6b3

hi Identifier     guifg=#dcc7c0 gui=italic
hi Function       guifg=#f06a7f gui=bold

hi Keyword        guifg=#ef4761 gui=bold
hi Statement      guifg=#f06a7f gui=bold
hi Conditional    guifg=#ef4761 gui=bold
hi Repeat         guifg=#ef4761 gui=bold

hi Type           guifg=#e8a15b gui=bold
hi StorageClass   guifg=#e8a15b gui=bold
hi Structure      guifg=#e8a15b gui=bold
hi Typedef        guifg=#e8a15b gui=bold

hi Constant       guifg=#f2b8a0
hi Number         guifg=#f2b8a0
hi Boolean        guifg=#f2b8a0 gui=bold

hi PreProc        guifg=#e8a15b
hi Include        guifg=#ef4761 gui=bold

hi Special        guifg=#8a3345
hi SpecialChar    guifg=#b8dff2 gui=bold

" C/C++ específicos (igual)
hi cFormat        guifg=#f1d67a gui=bold
hi cSpecial       guifg=#b8dff2 gui=bold

" =====================================================
" Diagnósticos básicos (igual)
" =====================================================
hi Error          guifg=#ef4761
hi WarningMsg     guifg=#e8a15b
hi InfoMsg        guifg=#f2b8a0
