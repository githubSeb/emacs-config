;; Multiple cursors

(conf:add-to-path "multiple-cursors")

(require 'multiple-cursors)

(global-set-key (kbd "C-u") 'mc/mark-next-like-this)
(global-set-key (kbd "C-j") 'mc/mark-next-symbol-like-this)
(global-set-key (kbd "C-n") 'mc/skip-to-next-like-this)
(global-set-key (kbd "C-S-n") 'mc/unmark-previous-like-this)
