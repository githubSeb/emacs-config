;; Auto-complete setup

(conf:add-to-path)

(require 'auto-complete)
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories (format "%s/%s" (file-name-directory load-file-name) "ac-dict"))
(setq ac-comphist-file (format "%s/%s" (file-name-directory load-file-name) "ac-comphist.dat"))
(setq ac-auto-show-menu t)

(defun my-ac-setup-makefile()
  (setq ac-sources '(ac-source-dictionary ac-source-makefile-rules
  					  ac-source-makefile-current-dir)))

(setq-default ac-sources '(ac-source-abbrev ac-source-dictionary ac-source-words-in-same-mode-buffers))  
(setq ac-delay 0)
(add-hook 'makefile-mode-hook 'my-ac-setup-makefile)
(add-hook 'auto-complete-mode-hook 'ac-common-setup)
(global-auto-complete-mode t)
(global-set-key (kbd "M-SPC") 'ac-complete)
