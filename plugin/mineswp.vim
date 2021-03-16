" nnoremap <silent> <script> <Plug>(MineSweep-Start) :call <SID>start_game()<cr>

if !exists(":MineSweep")
    command -nargs=* MineSweep :call mineswp#start(<f-args>)
endif

