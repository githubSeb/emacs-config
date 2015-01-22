;; Setup company irony

(conf:add-to-path "company-irony")

(require 'company-irony)

(defun setup-irony-company ()
  "Setup irony-company"
  (company-irony-setup-begin-commands)
  (add-to-list 'company-backends 'company-irony)
  (setq company-backends (delete 'company-clang company-backends)))

;; (optional) adds CC special commands to `company-begin-commands' in order to
;; trigger completion at interesting places, such as after scope operator
;;     std::|
(add-hook 'irony-mode-hook 'setup-irony-company)
