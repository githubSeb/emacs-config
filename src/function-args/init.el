;; configure function args

(conf:add-to-path "function-args")
(conf:add-to-path "helm")

(require 'function-args)
(fa-config-default)
(global-set-key (kbd "M-m") 'moo-jump-local)
