;; Configure helm

(conf:add-to-path "helm")

(require 'helm-config)

(global-set-key (kbd "M-f") 'helm-occur)
