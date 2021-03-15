let s:logo = '✠✠✠'
let s:title = 'Vim Mine Sweeping'
let s:win = '     You Win!    '
let s:lose = '     You Lose    '
let s:result = 'Score:'

function! s:create_board()
    setlocal modifiable
    normal! gg_dG
    call setline(1,printf("%s   %s   %s%d",s:logo,s:title,s:result,b:score))
    call append(line('$'),'')
    let b:startline = line('$')

    let nrow = b:nrow
	let ncol = b:ncol 
    let topline = "╭" .. repeat("───┬",ncol-1) .. "───╮"
    call append(line('$'),topline)

    let  labelrow = "" .. repeat("│   ",ncol) .. "│"
    let  linerow  = "├" .. repeat("───┼",ncol-1) .. "───┤"
    for _ in range(nrow-1)
        call append(line('$'),labelrow)
        call append(line('$'),linerow)
    endfor
    call append(line('$'),labelrow)

    let botline = "╰" .. repeat("───┴",ncol-1) .. "───╯"
    call append(line('$'),botline)
    setlocal nomodifiable
    " set cursor initial postion
    let [iline,ivcol] = s:get_window_pos_from_board_pos((b:nrow-1)/2,(b:ncol-1)/2)
    let bytescol = strlen(strcharpart(getline(iline),0,ivcol))
    call cursor(iline,bytescol)
endfunction

function! s:get_board_pos_from_window_pos(wline,wvcol)
    " wvcol should be virtcol number
    let loffset =  (a:wline - b:startline) % 2 
    if loffset == 0
        let grow = (a:wline- b:startline) / 2 - 1
    else 
        " screen pos on gird line not in cell
        return [-1,-1]
    endif
    let voffset = (a:wvcol - 1)%4
    if voffset > 0 
        let l:gcol = (a:wvcol-1)/4
        return [grow,gcol]
    else 
        " screen pos on gird line not in cell
        return [-1,-1] 
    endif
endfunction

function! s:get_window_pos_from_board_pos(grow,gcol)
    let wline = (a:grow + 1) * 2 + b:startline
    let wvcol = (a:gcol * 4) + 3 
    " wvcol is virtcol number
    return [wline,wvcol]
endfunction

function! s:get_rand_int(Low, High) abort
    let l:milisec = str2nr(matchstr(reltimestr(reltime()), '\v\.\zs\d+'))
    return l:milisec % (a:High - a:Low + 1) + a:Low
endfunction

function! s:create_mine()
	let mines = []
	let all = b:nrow * b:ncol
    " there may be same numbers in randint generation , so generated mines may less than b:nmine
    " use 1.3 as factor to increase the random num
	for _ in range(float2nr(b:nmine*1.3))
        let randnum = s:get_rand_int(0,all-1)
        if index(mines,randnum) < 0
            call add(mines,randnum)
        endif
	endfor
    let mines = mines[:b:nmine-1]
    " echom "init mines = "..b:nmine

    " reset the real b:nmine
    let b:nmine = len(mines)
    " echom "real mines = "..b:nmine
	for i in range(b:nrow)
        call add(b:board,[])
		for j in range(b:ncol)
            if index(mines,i*b:ncol+j)>=0
                call add(b:board[i],-1)
            else
                call add(b:board[i],0)
            endif
        endfor
    endfor
endfunction

function! s:count_mine()
	for i in range(b:nrow)
		for j in range(b:ncol)
            if b:board[i][j]==0
                for [x,y] in [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]
                    if i+y>=0 && i+y<b:nrow && j+x>=0 && j+x<b:ncol && b:board[i+y][j+x]==-1
                        let b:board[i][j] += 1
                    endif
                endfor
            endif
        endfor
    endfor
endfunction

function! s:get_cell(grow,gcol)
    let [wline,wvcol] = s:get_window_pos_from_board_pos(a:grow,a:gcol)
    return strcharpart(getline(wline),wvcol-2,3)
endfunction

function! s:replace_cell(grow,gcol,newcell)
    let [wline,wvcol] = s:get_window_pos_from_board_pos(a:grow,a:gcol)
    let curtext = getline(wline)
    let newtext = strcharpart(curtext,0,wvcol-2) .. a:newcell .. strcharpart(curtext,wvcol+1)
    call setline(wline,newtext)
endfunction

function! s:reveal_cell(flag)
    let wline = line('.')
    let wvcol = virtcol('.')
    let [grow,gcol] = s:get_board_pos_from_window_pos(wline,wvcol)
    if grow !=-1 && gcol != -1 
        setlocal modifiable
        let label = b:board[grow][gcol]
        let curcell = s:get_cell(grow,gcol)
        if a:flag == 1
            if curcell == '   '
                call s:replace_cell(grow,gcol,' + ')
            elseif curcell == ' + '
                call s:replace_cell(grow,gcol,'   ')
            endif
        elseif curcell == '   '
            if label == -1
                call s:replace_cell(grow,gcol,' * ')
                if b:start == 1
                    call setline(1,printf("%s   %s   %s%d",s:logo,s:lose,s:result,b:score))
                    let b:start = 0
                endif
            elseif label == 0
                call s:replace_cell(grow,gcol,' - ')
                let b:score += 1
                call add(b:blanks,[grow,gcol])
                call s:reveal_blank(grow,gcol)
                for [arow,acol] in b:blanks
                    let alabel =b:board[arow][acol]
                    let anewcell = alabel == 0 ? ' - ' : ' '..alabel..' '
                    let acurcell = s:get_cell(arow,acol)
                    if acurcell == '   ' || acurcell == ' + '
                        call s:replace_cell(arow,acol,anewcell)
                        let b:score += 1
                    endif
                endfor
                let b:blanks = []
            else
                let newcell = ' '..label..' '
                call s:replace_cell(grow,gcol,newcell)
                let b:score += 1
            endif
            if b:start== 1 
                if b:score == b:nrow*b:ncol-b:nmine
                    call setline(1,printf("%s   %s   %s%d",s:logo,s:win,s:result,b:score))
                    let b:start=0
                else
                    call setline(1,printf("%s   %s   %s%d",s:logo,s:title,s:result,b:score))
                endif
            endif 
        endif
        setlocal nomodifiable
    endif
endfunction

function! s:reveal_blank(l,c)
    let i=a:l
    let j=a:c
    for [x,y] in [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]
        let ni = i+y
        let nj = j+x
        if ni>=0 && ni<b:nrow && nj>=0 && nj<b:ncol
            if index(b:blanks,[ni,nj]) == -1
                call add(b:blanks,[ni,nj])
                if b:board[ni][nj]==0
                    call s:reveal_blank(ni,nj)
                endif
            endif
        endif
    endfor
endfunction

function! s:new_game()
    let b:board = []
    let b:blanks = []  "use dict may be better
    let b:score = 0
    call s:create_mine()
    call s:count_mine()
    call s:create_board()
    let b:start = 1
endfunction

" for test
function! PrintBoard()
    setlocal modifiable
    let startline = b:startline + 2*b:nrow + 2
    call setline(startline,"Show Board")
    for i in range(b:nrow)
        call append(line('$'),join(b:board[i],'.'))
    endfor
    setlocal nomodifiable
endfunction

function! s:move_right() abort
    let curvcol = virtcol('.')
    let [grow,gcol] = s:get_board_pos_from_window_pos(line('.'),curvcol) 
    if grow == -1 && gcol == -1
        return "2l"
    elseif gcol == b:ncol -1
        let [wline,newvcol] = s:get_window_pos_from_board_pos(grow,gcol)
        if newvcol > curvcol
            return "l"
        elseif newvcol < curvcol
            return "h"
        else
            return "hl"
        endif
    else
        let [wline,newvcol] = s:get_window_pos_from_board_pos(grow,gcol+1)
        return (newvcol-curvcol).."l"
    endif
endfunction

function! s:move_left() abort
    let curvcol = virtcol('.')
    let [grow,gcol] = s:get_board_pos_from_window_pos(line('.'),curvcol) 
    if grow == -1 && gcol == -1
        return "2h"
    elseif gcol == 0
        let [wline,newvcol] = s:get_window_pos_from_board_pos(grow,gcol)
        if newvcol > curvcol
            return "l"
        elseif newvcol < curvcol
            return "h"
        else
            return "lh"
        endif
    else
        let [wline,newvcol] = s:get_window_pos_from_board_pos(grow,gcol-1)
        return (curvcol-newvcol).."h"
    endif
endfunction

function! s:move_down() abort
    let curline = line('.')
    let [grow,gcol] = s:get_board_pos_from_window_pos(curline,virtcol('.')) 
    if grow == -1 && gcol == -1
        return "j"
    elseif grow == s:nrow -1
        return "kj"
    else
        return "2j"
    endif
endfunction

function! s:move_up() abort
    let curline = line('.')
    let [grow,gcol] = s:get_board_pos_from_window_pos(curline,virtcol('.')) 
    if grow == -1 && gcol == -1
        return "k"
    elseif grow == 0
        return "jk"
    else
        return "2k"
    endif
endfunction

function! s:start_game()
    vnew 
    call s:init_setting()
    let b:nrow = s:nrow
    let b:ncol = s:ncol
    let b:nmine = s:nrow*s:ncol *8/35
    call s:new_game()
    " echom b:board
    " should avoid click mine in fisrt try , todo
endfunction

function! s:init_setting()
    setlocal buftype=nofile bufhidden=wipe nobuflisted nomodifiable nolist noswapfile 
             \ nowrap nocursorline nocursorcolumn nospell
    setfiletype mineswp
    nnoremap <silent> <buffer> <2-LeftMouse> :call <SID>reveal_cell(0)<cr>
    nnoremap <silent> <buffer> <RightMouse> :call <SID>reveal_cell(1)<cr>
    nnoremap <silent> <buffer> c :call <SID>reveal_cell(0)<cr>
    nnoremap <silent> <buffer> f :call <SID>reveal_cell(1)<cr>
    nnoremap <silent> <buffer> ng :call <SID>new_game()<cr>

    nnoremap <silent> <buffer> <expr> h <SID>move_left() 
    nnoremap <silent> <buffer> <expr> l <SID>move_right()
    nnoremap <silent> <buffer> <expr> j <SID>move_down()
    nnoremap <silent> <buffer> <expr> k <SID>move_up()
endfunction


function! mineswp#start(...) abort
    if a:0 == 2 && a:1 > 0 && a:1 <= 30 && a:2 > 0 && a:2 <= 50
        let s:nrow = str2nr(a:1)
        let s:ncol = str2nr(a:2)
    else 
        let s:nrow = 14
        let s:ncol = 25
    endif
    call s:start_game()
endfunction

" nnoremap <silent> <script> <Plug>(MineSweep-Start) :call <SID>start_game()<cr>

if !exists(":MineSweep")
    command -nargs=* MineSweep :call mineswp#start(<f-args>)
endif

