;; Setup undo-tree

(conf:add-to-path)

(require 'undo-tree)
(global-undo-tree-mode 1)
(defalias 'redo 'undo-tree-redo)
(global-set-key (kbd "C-_") 'undo)
(global-set-key (kbd "M-_") 'redo)
