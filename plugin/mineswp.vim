let s:nrow = 12   "14
let s:ncol = 20  "25
let s:nbomb = 35   "80
let s:board = []
let s:blanks = []  "use dict may be better

" can use append（linenumber，List[linetext]）
function! s:create_board()
    set modifiable
	let row = s:nrow
	let col = s:ncol 
    let topboarder = "╭" .. repeat("───┬",col-1) .. "───╮"
    call append(line('$'),topboarder)

    let  labelrow = "" .. repeat("│   ",col) .. "│"
    let  linerow  = "├" .. repeat("───┼",col-1) .. "───┤"
    for i in range(1,row-1,1)
        call append(line('$'),labelrow)
        call append(line('$'),linerow)
    endfor
    call append(line('$'),labelrow)

    let botboarder = "╰" .. repeat("───┴",col-1) .. "───╯"
    call append(line('$'),botboarder)
    set nomodifiable
endfunction

function! s:get_board_pos_from_window_pos(wline,wvcol)
    " wvcol should be virtcol number
    let loffset =  (a:wline - s:startline) % 2 
    if loffset == 0
        let grow = (a:wline- s:startline) / 2 - 1
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
    let wline = (a:grow + 1) * 2 + s:startline
    let wvcol = (a:gcol * 4) + 3 
    " wvcol is virtcol number
    return [wline,wvcol]
endfunction


function! s:get_cell_pos()
    let cline = line('.')
    let chridx = virtcol('.')-1
    let curline = getline('.')
    let cell1 = strcharpart(curline,chridx-2,3)
    let cell2 = strcharpart(curline,chridx-1,3)
    let cell3 = strcharpart(curline,chridx,3) 
    if cell1 =~ '\v\s[ \+]\s' 
        " echom "cell1"
        return [cline,chridx]
    elseif  cell2 =~ '\v\s[ \+]\s' 
        " echom "cell2"
        return [cline,chridx+1]
    elseif cell3 =~ '\v\s[ \+]\s'
        " echom "cell3"
        return [cline,chridx+2]
    else
        return [0,0]
    endif
endfunction

function! s:get_rand_int(Low, High) abort
    let l:milisec = str2nr(matchstr(reltimestr(reltime()), '\v\.\zs\d+'))
    return l:milisec % (a:High - a:Low + 1) + a:Low
endfunction

function! s:create_mine()
	let bombs = []
	let all = s:nrow * s:ncol
	for _ in range(0,s:nbomb-1,1)
        " there may be same numbers , so generated bombs may less than s:nbomb, Todo
		call add(bombs,s:get_rand_int(0,all-1))
	endfor
	for i in range(0,s:nrow-1,1)
        call add(s:board,[])
		for j in range(0,s:ncol-1,1)
            if index(bombs,i*s:ncol+j)>=0
                call add(s:board[i],-1)
            else
                call add(s:board[i],0)
            endif
        endfor
    endfor
endfunction

function! s:count_mine()
	for i in range(0,s:nrow-1,1)
		for j in range(0,s:ncol-1,1)
            if s:board[i][j]==0
                for [x,y] in [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]
                    if i+y>=0 && i+y<s:nrow && j+x>=0 && j+x<s:ncol && s:board[i+y][j+x]==-1
                        let s:board[i][j] += 1
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
        set modifiable
        let label = s:board[grow][gcol]
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
            elseif label == 0
                call s:replace_cell(grow,gcol,' - ')
                call add(s:blanks,[grow,gcol])
                call s:reveal_blank(grow,gcol)
                for [arow,acol] in s:blanks
                    let alabel =s:board[arow][acol]
                    let anewcell = alabel == 0 ? ' - ' : ' '..alabel..' '
                    let acurcell = s:get_cell(arow,acol)
                    if acurcell == '   ' || acurcell == ' + '
                        call s:replace_cell(arow,acol,anewcell)
                    endif
                endfor
                let s:blanks = []
            else
                let newcell = ' '..label..' '
                call s:replace_cell(grow,gcol,newcell)
            endif
        endif
        set nomodifiable
    endif
endfunction

function! s:reveal_blank(l,c)
    let i=a:l
    let j=a:c
    for [x,y] in [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]
        let ni = i+y
        let nj = j+x
        if ni>=0 && ni<s:nrow && nj>=0 && nj<s:ncol
            if index(s:blanks,[ni,nj]) == -1
                call add(s:blanks,[ni,nj])
                if s:board[ni][nj]==0
                    call s:reveal_blank(ni,nj)
                endif
            endif
        endif
    endfor
endfunction

" for test
function! PrintBoard()
    set modifiable
    let startline = s:startline + 2*s:nrow + 2
    call setline(startline,"Show Board")
    for i in range(s:nrow)
        call append(line('$'),join(s:board[i],'.'))
    endfor
    set nomodifiable
endfunction

function! s:move_right() abort
    let linetext = getline('.')
    let maxcol = strdisplaywidth(linetext) 
    let curcol = virtcol('.')
    let curchar = strcharpart(linetext,curcol-1,1)
    if curchar == ' ' 
        if curcol+3 < maxcol
            return "w2l"
        else
            return "b2l"
        endif
    else
        return "2l"
    endif
endfunction

function! s:move_left() abort
    let linetext = getline('.')
    let curcol = virtcol('.')
    let curchar = strcharpart(linetext,curcol-1,1)
    if curchar == ' ' 
        if curcol > 4
            return "b2h"
        else
            return "w2h"
        endif
    else
        return "2h"
    endif
endfunction

function! s:move_down() abort
    let lineno = line('.')
    let rlineno = lineno-s:startline
    if rlineno % 2 == 1 
        if rlineno >= 2*s:nrow + 1  
            return "k"
        else
            return "j"
        endif
    else
        if rlineno >= 2*s:nrow
            return "jk"
        else
            return "2j"
    endif
endfunction
 
function! s:move_up() abort
    let lineno = line('.')
    let rlineno = lineno-s:startline
    if rlineno % 2 == 1 
        if rlineno <= 1 
            return "j"
        else
            return "k"
        endif
    else
        if rlineno <= 2
            return "kj"
        else
            return "2k"
    endif
endfunction
 
function! s:start_game()
    vnew 
    setlocal buftype=nofile bufhidden=wipe nobuflisted nomodifiable nolist noswapfile 
             \ nowrap nocursorline nocursorcolumn nospell
    setfiletype mineswp
    let s:startline = line('$')
    call s:create_mine()
    call s:count_mine()
    call s:create_board()
    " echom s:board
    " should avoid click mine in fisrt try , todo
    nnoremap <silent> <buffer> <2-LeftMouse> :call <SID>reveal_cell(0)<cr>
    nnoremap <silent> <buffer> <RightMouse> :call <SID>reveal_cell(1)<cr>
    nnoremap <silent> <buffer> c :call <SID>reveal_cell(0)<cr>
    nnoremap <silent> <buffer> f :call <SID>reveal_cell(1)<cr>

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
    let s:nbomb = s:nrow*s:ncol *8/35
    call s:start_game()
endfunction

" nnoremap <silent> <script> <Plug>(MineSweep-Start) :call <SID>start_game()<cr>

if !exists(":MineSweep")
    command -nargs=* MineSweep :call mineswp#start(<f-args>)
endif

