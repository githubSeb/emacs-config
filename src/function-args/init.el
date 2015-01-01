;; configure function args

(conf:add-to-path "function-args")
(conf:add-to-path "helm")

(require 'function-args)
(fa-config-default)
(setq moo-do-includes nil)

(global-set-key (kbd "M-m") 'moo-jump-local)

(defun function-args--set-faces (frame)
  (with-selected-frame frame
    (set-face-attribute 'helm-selection nil :background nil :underline nil :inherit 'region)))

(function-args--set-faces (selected-frame))
(add-hook 'after-make-frame-functions 'function-args--set-faces)
