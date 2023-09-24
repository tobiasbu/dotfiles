# Vim Commands

Files:

- `:saveas FILE_NAME` - duplicate current file

Find and Replace:

- `:s/FIND_WORD/REPLACE_WORD` - find and replace first occurance in the current line
- `:s/FIND/REPLACE/g` - find & replace all occurances in the current line
- `%:s/FIND/REPLACE/g` - find & replace all occurances in the entire file

Cut, Copy, Paste, Delete:

- dd = cut current line
- yy = Copy current line
- P = paste
- gD = delete all lines below until EOF

## Windowing

### Shortcuts

Splitting windows:

- CTRL + W + S = `:split` - Split current opened window in two
- CTRL + W + O = `:only` make current window the only opened

Opening and closing windows:

- CTRL + W + N = `:new` - Open new window overlaying the current opened 
- CTRL + W + C = Close current window
- CTRL + W + Q = `:quit` - Close current window. If there's no more window vim quits

Navigating:

CTRL + W + W = Alternates between windows
CTRL + W + J = Go down window (j)
CTTL + W + K = Go up window (k)
CTRL + W + R = Rotates window

### Commands

- `:wall` - save opened windows
- `:qall` - close all opened windows

