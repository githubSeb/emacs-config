;; Configure company c header

(conf:add-to-path "company-c-header")

(require 'company-c-headers)

(eval-after-load 'company
  '(add-to-list 'company-backends 'company-c-headers))
