if exists("b:current_syntax")
    finish
endif

hi Grid   gui=bold guifg=Grey ctermfg=Grey
hi Flag   gui=bold guifg=Black guibg=Green ctermfg=Black ctermbg=Green
hi Mine   gui=bold guifg=Black guibg=Red ctermfg=Black ctermbg=Red
hi Blank  gui=bold
hi Button gui=bold 

hi Label1 gui=bold guifg=DarkRed guibg=Gray ctermfg=DarkRed ctermbg=Gray  
hi Label2 gui=bold guifg=DarkBlue guibg=Gray ctermfg=DarkBlue ctermbg=Gray  
hi Label3 gui=bold guifg=DarkYellow guibg=Gray ctermfg=DarkYellow ctermbg=Gray  
hi Label4 gui=bold guifg=Purple guibg=Gray ctermfg=Magenta ctermbg=Gray  
hi Label5 gui=bold guifg=LightRed guibg=Gray ctermfg=LightRed ctermbg=Gray  
hi Label6 gui=bold guifg=Cyan guibg=Gray ctermfg=DarkCyan ctermbg=Gray  
hi Label7 gui=bold guifg=Yellow guibg=Gray ctermfg=Yellow ctermbg=Gray  
hi Label8 gui=bold guifg=White guibg=Gray ctermfg=White ctermbg=Gray  

hi LogoLabel gui=bold guifg=Gray ctermfg=Gray
hi TitleLabel gui=bold guifg=Black guibg=Gray ctermfg=Black ctermbg=Gray
hi WinLabel gui=bold guifg=Black guibg = Green ctermfg=Black ctermbg=Green
hi LoseLabel gui=bold guifg=Black guibg = Red ctermfg=Black ctermbg=Red

hi HelpLabel gui=bold guifg =Gray ctermfg=Gray
hi ActionName gui=bold guifg=Gray ctermfg=Gray
hi ActionKey gui=bold guifg=Gray ctermfg=Gray

syn match GridLine '│'
syn match GridLine '─'
syn match GridLine '╭'
syn match GridLine '╰'
syn match GridLine '┬'
syn match GridLine '┴'
syn match GridLine '╮'
syn match GridLine '╯'
syn match GridLine '┼'
syn match GridLine '├'
syn match GridLine '┤'
syn match GridLine '┌' 
syn match GridLine '└'
syn match GridLine '┐'
syn match GridLine '┘'

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

syn match GameLogo '*'
hi link GameLogo LogoLabel
syn match GameTitle '\v\*+\s+.*Mine.*:\d+/\d+\s+\*+'
hi link GameTitle TitleLabel
syn match GameWin '\v\*+\s+.*Won.*:\d+/\d+\s+\*+'
hi link GameWin WinLabel
syn match GameLose '\v\*+\s+.*Lost.*:\d+/\d+\s+\*+'
hi link GameLose LoseLabel

syn match HelpLine '\v\-.*Help.*\-'
hi link HelpLine HelpLabel
syn match GameAction '\v\[.+\]'
hi link GameAction ActionName
syn keyword KeyMap h j k l c f ng pb
hi link KeyMap ActionKey
syn match SKeyMap '←'
syn match SKeyMap '↓'
syn match SKeyMap '↑'
syn match SKeyMap '→'
syn match SKeyMap '\v\<.{-}\>'
hi link SKeyMap ActionKey

let b:current_syntax = "mineswp"
