;; Autopair

(conf:add-to-path)

(require 'autopair)
(autopair-global-mode t)
(setq autopair-autowrap t)
(setq autopair-blink nil)

(defun disable-autopair()
  (autopair-global-mode -1)
  (electric-pair-mode))
