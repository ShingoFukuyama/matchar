
# What can do with Emacs matchar.el
Move cursor to a character repeatedly with sequential input.

![matchar](https://github.com/ShingoFukuyama/matchar/raw/master/img/matchar.gif)

`M-x matchar-forward a a a b b f f ...`  
`M-x matchar-backward a a a b b f f ...`

## config

```elisp
;; Locate the matchar folder to your path
(add-to-list 'load-path "~/.emacs.d/elisp/matchar")
(require 'matchar)
;; Change keybinds to whatever you like :)
(global-set-key (kbd "M-f") 'matchar-forward)
(global-set-key (kbd "M-b") 'matchar-backward)
```
