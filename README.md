# vim-mine-sweeping
<font size=4>mine sweeping game in vim and neovim</font>

## ScreenShot

![screenshotdark](https://user-images.githubusercontent.com/13008913/111631101-fe858080-882d-11eb-9484-baa544087f20.png =500x500)
---
![screenshotlight](https://user-images.githubusercontent.com/13008913/111631149-09401580-882e-11eb-8a99-4fde0197c892.png =500x500)

## Installation
```vimscript
" vim-plug
Plug 'iqxd/vim-mine-sweeping'
```
## Usage
* Launch `Vim Mine Sweeping` with command `:MineSweep`
* Press <kbd>h</kbd>, <kbd>j</kbd>, <kbd>k</kbd>, <kbd>l</kbd> to move between cells
* Press <kbd>c</kbd> to reveal a cell, <kbd>f</kbd> to add flag on a cell
* Press <kbd>n</kbd> <kbd>g</kbd> to start a new game, <kbd>?</kbd> to toggle help

## Options
Command `:MineSweep` can be called with following arugments:
> `:MineSweep`  `easy | medium | hard | row col`  `-e | -n | -v | -t`
* `easy`  9 x 9 board
* `medium`  16 x 16 board
* `hard`  24 x 24 board
* `row col` user defined row x col Board
* `-e` create board in current window
* `-n` create board in new split window
* `-v` create board in new vsplit window
* `-t` create board in new tabpage

The default `:MineSweep` are equal to command with arguments like:
> `:MineSweep` `12 20` `-v`

which create game with 12 x 20 board in a new vsplit window

You can also map the command in vimrc like below
```vimscript
nnoremap <F12> :MineSweep medium -t<cr>
```

---
<font size=4>*Enjoy!*  :)</font>


