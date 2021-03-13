let s:nrow = 12   "14
let s:ncol = 20  "25
let s:nbomb = 35   "80
let s:board = []
let s:blanks = []  "use dict may be better

" can use append（linenumber，List[linetext]）
function! s:create_board()
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

function! s:reveal_cell(isflag)
    " ci is virtual col numbe
    let [l,vc] = s:get_cell_pos()
    " echom [l,c]
    if [l,vc]!=[0,0]
        let crow = (l-s:startline)/2-1
        let ccol = (vc-3)/4 
        let label = s:board[crow][ccol]
        if a:isflag == 1
            let cell = ' + '
        elseif label == -1
            let cell = ' * '
        elseif label == 0
            let cell = ' - '
            call add(s:blanks,[crow,ccol])
            call s:reveal_blank(crow,ccol)
            for [br,bc] in s:blanks
                let bl = (br+1)*2+s:startline
                let vcol = bc*4+3
                let curbline = getline(bl)
                let blabel =s:board[br][bc]
                let bcell = blabel == 0 ? ' - ' : ' '..blabel..' '
                let newbline = strcharpart(curbline,0,vcol-2)..bcell..strcharpart(curbline,vcol+1)
                call setline(bl,newbline)
            endfor
            let s:blanks = []
        else
            let cell = ' '..label..' '
        endif
        let curline = getline(l)
        let curcell = strcharpart(curline,vc-2,3)
        " cancel click
        if a:isflag == 1 && curcell == ' + '
            let cell = '   '
        endif
        let newline = strcharpart(curline,0,vc-2)..cell..strcharpart(curline,vc+1)
        call setline(l,newline)
        

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

function! s:move_right() abort
    let linetext = getline('.')
    let maxcol = strdisplaywidth(linetext) 
    let curcol = virtcol('.')
    let curchar = strcharpart(linetext,curcol-1,1)
    if curchar == ' ' 
        if curcol+3 < maxcol
            return "w2l"
        else
            return "\<nop>"
        endif
    else
        return "2l"
    endif
endfunction

function! s:move_left() abort
    let linetext = getline('.')
    let maxcol = strdisplaywidth(linetext) 
    let curcol = virtcol('.')
    let curchar = strcharpart(linetext,curcol-1,1)
    if curchar == ' ' 
        if curcol > 4
            return "b2h"
        else
            return "\<nop>"
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
            return "\<nop>"
        else
            return "j"
        endif
    else
        if rlineno >= 2*s:nrow
            return "\<nop>"
        else
            return "2j"
    endif
endfunction
 
function! s:move_up() abort
    let lineno = line('.')
    let rlineno = lineno-s:startline
    if rlineno % 2 == 1 
        if rlineno <= 1 
            return "\<nop>"
        else
            return "k"
        endif
    else
        if rlineno <= 2
            return "\<nop>"
        else
            return "2k"
    endif
endfunction
 
function! s:start_game()
    vnew 
    " should add modifiable nomodifiable when write
    setlocal buftype=nofile bufhidden=wipe nobuflisted nolist noswapfile 
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
