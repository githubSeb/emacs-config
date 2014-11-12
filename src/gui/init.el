;; Setup emacs in gui mode

(if (not (display-graphic-p))
    (throw 'load-module-exception "Emacs not in gui mode"))

;; Remove all the crap
(menu-bar-mode -1)
(blink-cursor-mode 0)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(global-unset-key (kbd "C-z"))
(normal-erase-is-backspace-mode 1)
