;; Init company mode

(conf:add-to-path "company")

(require 'company)

(setq company-idle-delay 0)
(setq company-minimum-prefix-length 1)

(dolist (hook (list
               'emacs-lisp-mode-hook
               'lisp-mode-hook
               'lisp-interaction-mode-hook
               'scheme-mode-hook
               'java-mode-hook
               'c-mode-hook
               'c++-mode-hook
               'haskell-mode-hook
               'asm-mode-hook
               'emms-tag-editor-mode-hook
               'sh-mode-hook
               ))
  (add-hook hook 'company-mode))

(defun cc-company-setup ()
  (setq company-backends (delete 'company-semantic company-backends)))

(add-hook 'c-mode-hook 'cc-company-setup)
(add-hook 'c++-mode-hook 'cc-company-setup)
