let s:logo  = '*'
let s:title = 'Vim Mine Sweeping  Score:'
let s:win   = 'You Won The Game!  Score:'
let s:lose  = 'You Lost The Game  Score:'
let s:help  = 'Toggle Help : ?'
let s:help1 = "[Move]    : h j k l or ← ↓ ↑ →"
let s:help2 = '[Reveal]  : c or <2-leftmouse>'
let s:help3 = '[Flag]    : f or <rightmouse>'
let s:help4 = '[NewGame] : ng'
let s:help5 = '[PrintBoard] : pb'

function! s:create_board()
    setlocal modifiable
    silent! normal! gg_dG
    call setline(1,'')

    let nrow = b:nrow
	let ncol = b:ncol 
    let topline = "┌" .. repeat("───┬",ncol-1) .. "───┐"

    let b:boardwidth = strdisplaywidth(topline)

    " add title line
    let b:titleline = line('$') + 1
    call s:set_titleline(s:title,0)
    call append(line('$'),'')
    let b:startline = line('$')

    call append(line('$'),topline)
    let  labelrow = "" .. repeat("│   ",ncol) .. "│"
    let  linerow  = "├" .. repeat("───┼",ncol-1) .. "───┤"
    for _ in range(nrow-1)
        call append(line('$'),labelrow)
        call append(line('$'),linerow)
    endfor
    call append(line('$'),labelrow)

    let botline = "└" .. repeat("───┴",ncol-1) .. "───┘"
    call append(line('$'),botline)

    " set cursor initial postion
    let [iline,ivcol] = s:get_window_pos_from_board_pos((b:nrow-1)/2,(b:ncol-1)/2)
    let bytescol = strlen(strcharpart(getline(iline),0,ivcol))
    call cursor(iline,bytescol)

    " add help line
    call append(line('$'),'')
    let b:helpline = line('$') + 1
    call s:set_helpline()

    setlocal nomodifiable
endfunction

function! s:set_titleline(text,score)
    let title = printf("%s  %s%d/%d  %s",s:logo,a:text,a:score,b:total,s:logo)
    let titlewidth = strdisplaywidth(title)
    if titlewidth >= b:boardwidth
        call setline(b:titleline,title)
    else
        let rest = b:boardwidth - titlewidth
        let leftfills = repeat(s:logo,rest/2)
        let rightfills = repeat(s:logo,rest/2+rest%2)
        call setline(b:titleline,leftfills..title..rightfills)
    endif
endfunction

function! s:set_helpline()
    let fillchar = '-'
    let helptext = printf("%s  %s  %s",fillchar,s:help,fillchar)
    let helpwidth = strdisplaywidth(helptext)
    if helpwidth >= b:boardwidth
        call setline(b:helpline,helptext)
    else
        let rest = b:boardwidth - helpwidth
        let leftfills = repeat(fillchar,rest/2)
        let rightfills = repeat(fillchar,rest/2+rest%2)
        call setline(b:helpline,leftfills..helptext..rightfills)
    endif
endfunction

function! s:get_board_pos_from_window_pos(wline,wvcol)
    " wvcol should be virtcol number
    let loffset =  (a:wline - b:startline) % 2 
    if loffset == 0
        let grow = (a:wline- b:startline) / 2 - 1
        if grow >= b:nrow
            return [-1,-1]
        endif
    else 
        " screen pos on gird line not in cell
        return [-1,-1]
    endif
    let voffset = (a:wvcol - 1)%4
    if voffset > 0 
        let gcol = (a:wvcol-1)/4
        if gcol >= b:ncol
            return [-1,-1]
        else
            return [grow,gcol]
        endif
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

function! s:get_rand_numbers(low, high, numcount,skipnums) abort
    let numbers = {}
    let numrange = a:high-a:low+1
    if exists("*rand")
        let seed = srand()
        for _ in range(a:numcount)
            let randnum = rand(seed) % numrange + a:low 
            let numbers[randnum] = 1
        endfor
    elseif has("nvim")
        call luaeval('math.randomseed(os.time())')
        for _ in range(a:numcount)
            let randnum = luaeval(printf("math.random(%d,%d)",a:low,a:high)) 
            let numbers[randnum] = 1
        endfor
    else
        for _ in range(a:numcount)
            let milisec = str2nr(matchstr(reltimestr(reltime()), '\v\.\zs\d+'))
            let randnum = milisec % numrange + a:low 
            let numbers[randnum] = 1
        endfor
    endif
    for skipnum in a:skipnums
        if has_key(numbers,skipnum)
            unlet numbers[skipnum]
        endif
    endfor
    let n = []
    for k in keys(numbers)
        call add(n,str2nr(k))
    endfor
    " echom n
    return n
endfunction

function! s:create_mine(grow,gcol)
    " (grow, gcol) is the first sweep cell , should be safe on the first try
    " for easier start in early game , first try is better to be emtpy cell (0), 
    " like windows minesweeper does
    let safenums = []
    for [x,y] in [[0,0],[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]
        let srow = a:grow + y 
        let scol = a:gcol + x
        if srow>=0 && srow<b:nrow && scol>=0 && scol<b:ncol
            call add(safenums,srow * b:ncol + scol)
        endif
    endfor

    " there may be same numbers in randint generation , so generated mines may less than b:nmine
    " use 1.3 as factor to increase the random num
    let nums_count = float2nr(b:nmine*1.3)
    let mines = s:get_rand_numbers(0,b:total-1,nums_count,safenums)

    let mines = mines[:b:nmine-1]
    " echom "init mines = "..b:nmine

    " reset the real b:nmine
    let b:nmine = len(mines)
    " echom "real mines = "..b:nmine
	for arow in range(b:nrow)
		for acol in range(b:ncol)
            if index(mines,arow*b:ncol+acol)>=0
                let b:board[arow..' '..acol] = -1
            else
                let b:board[arow..' '..acol] = 0
            endif
        endfor
    endfor
endfunction

function! s:count_mine()
	for grow in range(b:nrow)
		for gcol in range(b:ncol)
            if b:board[grow .. ' ' ..gcol]==0
                for [x,y] in [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]
                    let arow = grow + y 
                    let acol = gcol + x
                    if arow>=0 && arow<b:nrow && acol>=0 && acol<b:ncol && b:board[arow..' '..acol]==-1
                        let b:board[grow..' '..gcol] += 1
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
        if b:score == 0
            call s:create_mine(grow,gcol)
            call s:count_mine()
        endif
        let label = b:board[grow..' '..gcol]
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
                    " call setline(1,printf("%s   %s   %s%d",s:logo,s:lose,s:result,b:score))
                    call s:set_titleline(s:lose,b:score)
                    let b:start = 0
                endif
            elseif label == 0
                call s:replace_cell(grow,gcol,' - ')
                let b:score += 1
                let b:blanks[grow..' '..gcol] = 1
                call s:reveal_blank(grow,gcol)
                for rc in keys(b:blanks)
                    let [arow,acol] = split(rc)
                    let arow = str2nr(arow)
                    let acol = str2nr(acol)
                    let alabel =b:board[arow..' '..acol]
                    let anewcell = alabel == 0 ? ' - ' : ' '..alabel..' '
                    let acurcell = s:get_cell(arow,acol)
                    if acurcell == '   ' || acurcell == ' + '
                        call s:replace_cell(arow,acol,anewcell)
                        let b:score += 1
                    endif
                endfor
                let b:blanks = {}
            else
                let newcell = ' '..label..' '
                call s:replace_cell(grow,gcol,newcell)
                let b:score += 1
            endif
            if b:start== 1 
                if b:score == b:total-b:nmine
                    " call setline(1,printf("%s   %s   %s%d",s:logo,s:win,s:result,b:score))
                    call s:set_titleline(s:win,b:total)
                    let b:start=0
                else
                    " call setline(1,printf("%s   %s   %s%d",s:logo,s:title,s:result,b:score))
                    call s:set_titleline(s:title,b:score)
                endif
            endif 
        endif
        setlocal nomodifiable
    endif
endfunction

function! s:reveal_blank(grow,gcol)
    for [x,y] in [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]
        let arow = a:grow+y
        let acol = a:gcol+x
        if arow>=0 && arow<b:nrow && acol>=0 && acol<b:ncol
            if !has_key(b:blanks,arow..' '..acol)
                let b:blanks[arow..' '..acol] = 1
                if b:board[arow..' '..acol]==0
                    call s:reveal_blank(arow,acol)
                endif
            endif
        endif
    endfor
endfunction

function! s:new_game()
    let b:board = {}
    let b:blanks = {}
    let b:score = 0
    call s:create_board()
    let b:start = 1
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
    let curvcol = virtcol('.')
    let [grow,gcol] = s:get_board_pos_from_window_pos(curline,curvcol) 
    if grow == -1 && gcol == -1
        return "j"
    else
        let [wline,newvcol] = s:get_window_pos_from_board_pos(grow,gcol)
        if newvcol > curvcol
            let rowmove = "l"
        elseif newvcol < curvcol
            let rowmove = "h"
        else
            let rowmove = ""
        endif
        if grow == b:nrow -1
            return rowmove == "" ? "kj" : rowmove
        else
            return rowmove .. "2j"
        endif
    endif
endfunction

function! s:move_up() abort
    let curline = line('.')
    let curvcol = virtcol('.')
    let [grow,gcol] = s:get_board_pos_from_window_pos(curline,curvcol) 
    if grow == -1 && gcol == -1
        return "k"
    else
        let [wline,newvcol] = s:get_window_pos_from_board_pos(grow,gcol)
        if newvcol > curvcol
            let rowmove = "l"
        elseif newvcol < curvcol
            let rowmove = "h"
        else
            let rowmove = ""
        endif
        if grow == 0
            return rowmove == "" ? "jk" : rowmove
        else
            return rowmove .. "2k"
        endif
    endif
endfunction

function s:toggle_help()
    setlocal modifiable
    if line('$') == b:helpline
        call append(line('$'),s:help1)
        call append(line('$'),s:help2)
        call append(line('$'),s:help3)
        call append(line('$'),s:help4)
        call append(line('$'),s:help5)
    else
        silent! normal! ma
        call cursor(b:helpline+1,1)
        silent! normal! dG
        silent! normal! `a
    endif
    setlocal nomodifiable
endfunction

function! s:open_float_win(fwin_width,fwin_height)
    let height = a:fwin_height
    let row = float2nr((&lines -2 - height) / 2)
    let width = a:fwin_width
    let col = float2nr((&columns - width) / 2)

    let opts = {
      \ 'relative': 'editor',
      \ 'style': 'minimal',
      \ 'width': width,
      \ 'height': height,
      \ 'col': col,
      \ 'row': row,
      \ }

    let buf = nvim_create_buf(v:false, v:true)
    let win = nvim_open_win(buf, v:true, opts)
    let b:fwin = win
endfunction


" for test
function! s:print_board()
    if b:score == 0
        echom "Reveal a cell before print the board"
    else
        setlocal modifiable
        for arow in range(b:nrow)
            let linetext = []
            for acol in range(b:ncol)
                let label = b:board[arow..' '..acol]
                if label == 0 
                    let label = '-'
                elseif label == -1
                    let label = '*'
                else
                    let label = string(label)
                endif
                call add(linetext," "..label.." ")
            endfor
            call append('$',join(linetext))
        endfor
        setlocal nomodifiable
    endif
endfunction

function! s:start_game() 
    call s:init_setting()
    let b:nrow = s:nrow
    let b:ncol = s:ncol
    let b:nmine = s:nmine 
    let b:total = s:nrow * s:ncol
    call s:new_game()
    " echom b:board
endfunction

function! s:init_setting()
    setlocal buftype=nofile bufhidden=wipe nobuflisted nomodifiable nolist noswapfile 
             \ nowrap nocursorline nocursorcolumn nospell maxfuncdepth=199
             \ encoding=utf8 noautoindent nosmartindent t_Co=256 mouse=a
    setfiletype mineswp
    nnoremap <silent> <buffer> <2-leftmouse> :call <SID>reveal_cell(0)<cr>
    nnoremap <silent> <buffer> <rightmouse> :call <SID>reveal_cell(1)<cr>
    nnoremap <silent> <buffer> c :call <SID>reveal_cell(0)<cr>
    nnoremap <silent> <buffer> f :call <SID>reveal_cell(1)<cr>
    nnoremap <silent> <buffer> ng :call <SID>new_game()<cr>
    nnoremap <silent> <buffer> ? :call <SID>toggle_help()<cr>
    nnoremap <silent> <buffer> pb :call <SID>print_board()<cr>

    nnoremap <silent> <buffer> <expr> h <SID>move_left() 
    nnoremap <silent> <buffer> <expr> l <SID>move_right()
    nnoremap <silent> <buffer> <expr> j <SID>move_down()
    nnoremap <silent> <buffer> <expr> k <SID>move_up()
    nnoremap <silent> <buffer> <expr> <left> <SID>move_left() 
    nnoremap <silent> <buffer> <expr> <right> <SID>move_right()
    nnoremap <silent> <buffer> <expr> <down> <SID>move_down()
    nnoremap <silent> <buffer> <expr> <up> <SID>move_up()
endfunction

function! mineswp#start(...) abort
    if a:0 >=1 && a:1 ==? "easy"
        let s:nrow = 9
        let s:ncol = 9
        let s:nmine = 11
    elseif a:0 >=1 && a:1 ==? "medium"
        let s:nrow = 16
        let s:ncol = 16
        let s:nmine = 42
    elseif a:0 >=1 && a:1 ==? "hard"
        let s:nrow = 24
        let s:ncol = 24
        let s:nmine = 102
    elseif a:0 >= 2 && a:1 =~ '\d\+' && a:2 =~ '\d\+' && a:1 >= 1 && a:1 <= 30 && a:2 >= 1 && a:2 <= 30
        let s:nrow = str2nr(a:1)
        let s:ncol = str2nr(a:2)
        let s:nmine = float2nr(s:nrow * s:ncol * 0.18)
    else 
        let s:nrow = 12
        let s:ncol = 20
        let s:nmine = float2nr(s:nrow * s:ncol * 0.18)
    endif

    if a:0 != 0
        let winloc = a:000[-1]
        if winloc ==? '-n'    
            new     " split window
        elseif winloc ==? '-v'
            vnew    " vsplit window
        elseif winloc ==? '-t'
            tabnew  " tabpage
        elseif winloc ==? '-e'
            enew    " current window
        elseif winloc ==? '-f' && has("nvim")
            " float window
            let fw_height = s:nrow*2+7
            let fw_width = s:ncol*4+1
            let fw_width_min = len(s:title)+6 
            let total = s:nrow*s:ncol
            if total < 10 
                let fw_width_min += 3
            elseif total < 100
                let fw_width_min += 5
            else
                let fw_width_min += 7
            endif
            if fw_width < fw_width_min
               let fw_width = fw_width_min
            endif
            call s:open_float_win(fw_width,fw_height)
        else
            vnew     " default
        endif
    else
        vnew    " default
    endif
    call s:start_game()
endfunction
