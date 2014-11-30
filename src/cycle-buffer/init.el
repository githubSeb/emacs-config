;; Cycle-buffer setup

(conf:add-to-path)

(require 'cycle-buffer)

(global-set-key [M-next] 'cycle-buffer)
(global-set-key [M-prior] 'cycle-buffer-backward)
