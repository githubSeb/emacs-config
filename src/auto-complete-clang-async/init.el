;; Setup auto-complete-clang-async

(conf:add-to-path)
(conf:require (list 'auto-complete))

(require 'auto-complete-clang-async)

;; @TODO - rename all this crap
;; This is the include list for C/C++
(setq azkae-include-list (split-string
"/usr/include/c++/4.8
/usr/include/x86_64-linux-gnu/c++/4.8
/usr/include/c++/4.8/backward
/usr/lib/gcc/x86_64-linux-gnu/4.8/include
/usr/local/include
/usr/lib/gcc/x86_64-linux-gnu/4.8/include-fixed
/usr/include/x86_64-linux-gnu
/usr/include"
))

;; This is the custom include list for C/C++ (will be filled with Makefile info in the futur)
(setq azkae-custom-include-list (split-string
""))

(setq azkae-additional-cflags (split-string
""))

(defun azkae-create-cflags ()
  (setq ac-clang-cflags
	(append (mapcar (lambda (item)(concat "-I" item)) azkae-include-list)
		(mapcar (lambda (item)(concat "-I" item)) azkae-custom-include-list)
		azkae-additional-cflags
		)))

(setq ac-clang-complete-executable (format "%s/%s" (file-name-directory load-file-name) "clang-complete"))

(defun ac-cc-mode-setup ()
  (global-set-key (kbd "M-SPC") 'ac-complete-clang-async)
  (azkae-create-cflags)
  (setq ac-sources '(ac-source-clang-async ac-sources-include-files-in-current-dir ac-sources-files-system ac-source-dictionary))
  (ac-clang-launch-completion-process)
  )

(add-hook 'c-mode-common-hook 'ac-cc-mode-setup)
(global-set-key (kbd "M-p") 'ac-clang-syntax-check)
