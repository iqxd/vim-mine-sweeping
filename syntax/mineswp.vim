if exists("b:current_syntax")
    finish
endif

hi Grid   gui=bold guifg=DarkCyan
hi Label  gui=bold guifg=black guibg=Gray 
hi Flag   gui=bold guifg=black guibg=LightGreen
hi Mine   gui=bold guifg=black guibg=red
hi Blank  gui=bold
hi Button gui=bold 

hi Label1 gui=bold guifg=blue guibg=Gray 
hi Label2 gui=bold guifg=orange guibg=Gray 
hi Label3 gui=bold guifg=yellow guibg=Gray 
hi Label4 gui=bold guifg=violet guibg=Gray 
hi Label5 gui=bold guifg=green guibg=Gray 
hi Label6 gui=bold guifg=brown guibg=Gray 
hi Label7 gui=bold guifg=cyan guibg=Gray 
hi Label8 gui=bold guifg=pink guibg=Gray 

syn match GridLine '│'
syn match GridLine '╭'
syn match GridLine '─'
syn match GridLine '╰'
syn match GridLine '┬'
syn match GridLine '┴'
syn match GridLine '╮'
syn match GridLine '╯'
syn match GridLine '┼'
syn match GridLine '├'
syn match GridLine '┤'

hi link GridLine Grid

syn match Number1Label '\v\s1\s'
hi link Number1Label Label1
syn match Number2Label '\v\s2\s'
hi link Number2Label Label2
syn match Number3Label '\v\s3\s'
hi link Number3Label Label3
syn match Number4Label '\v\s4\s'
hi link Number4Label Label4
syn match Number5Label '\v\s5\s'
hi link Number5Label Label5
syn match Number6Label '\v\s6\s'
hi link Number6Label Label6
syn match Number7Label '\v\s7\s'
hi link Number7Label Label7
syn match Number8Label '\v\s8\s'
hi link Number8Label Label8

" syn match FlagLabel '\v\s✘\s'
syn match FlagLabel '\v\s\+\s'
hi link FlagLabel Flag
" syn match MineLabel '\v\s❁\s'
syn match MineLabel '\v\s\*\s'
hi link MineLabel Mine

syn match ButtonCell '\v\s\s\s'
hi link ButtonCell Button
syn match BlankCell '\v\s\-\s'
hi link BlankCell Blank

let b:current_syntax = "potion"
