;; Setup emacs in gui mode

(if (not (display-graphic-p))
    (throw 'load-module-exception "Emacs not in gui mode"))

(global-unset-key (kbd "C-z"))
(normal-erase-is-backspace-mode 1)
