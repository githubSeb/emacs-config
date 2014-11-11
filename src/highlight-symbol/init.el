;; Hightlight symbol

(conf:add-to-path)

(require 'highlight-symbol)

(global-set-key [f7] 'highlight-symbol-at-point)
(global-set-key [(shift f7)] 'highlight-symbol-next)
(global-set-key [(control f7)] 'highlight-symbol-prev)
