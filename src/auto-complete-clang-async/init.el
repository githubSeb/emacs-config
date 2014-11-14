;; Setup auto-complete-clang-async

(conf:add-to-path "auto-complete-clang-async")
(conf:require (list 'auto-complete))

(require 'auto-complete-clang-async)

(defun get-string-from-file (filePath)
  "Return filePath's file content."
  (with-temp-buffer
    (insert-file-contents filePath)
    (buffer-string)))

(defun get-include-list()
  (let ((file (concat (file-name-directory load-file-name) "/includes")))
    (if (not (file-exists-p file))
	(throw 'load-module-exception "Include list file not found. Module is not properly installed")
      )
    (split-string (get-string-from-file file))))

;; @TODO - rename all this crap
;; This is the include list for C/C++
(setq azkae-include-list (get-include-list))

;; This is the custom include list for C/C++ (will be filled with Makefile info in the futur)
(setq azkae-custom-include-list (split-string
""))

(setq azkae-additional-cflags (split-string
""))

;; @TODO
(setq azkae-get-project-script (concat (file-name-directory load-file-name) "/get_project.sh"))

(defun azkae-create-cflags ()
  (setq ac-clang-cflags
	(append (mapcar (lambda (item)(concat "-I" item)) azkae-include-list)
		(mapcar (lambda (item)(concat "-I" item)) azkae-custom-include-list)
		azkae-additional-cflags
		)))

(setq ac-clang-complete-executable (format "%s/%s" (file-name-directory load-file-name)
					   "auto-complete-clang-async/clang-complete"))

(defun ac-cc-mode-setup ()
  (project-setup)
  (global-set-key (kbd "M-SPC") 'ac-complete-clang-async)
  (define-key ac-mode-map (kbd "M-:") 'ac-clang-jump-smart)
  (define-key ac-mode-map (kbd "M-!") 'ac-clang-jump-back)
  (define-key ac-mode-map (kbd "M-/") 'ac-clang-jump-definition)
  (azkae-create-cflags)
  (setq ac-sources '(ac-source-clang-async ac-sources-include-files-in-current-dir ac-sources-files-system ac-source-dictionary))
  (ac-clang-launch-completion-process))

(add-hook 'c-mode-common-hook 'ac-cc-mode-setup)
(global-set-key (kbd "M-p") 'ac-clang-syntax-check)

;; @TODO: emacsproject into other emacsproject should work
(defun project-setup()
  (interactive)
  (message "Loading project...")
  (setq azkae-project-dir (replace-regexp-in-string "\n$" "" (shell-command-to-string
							      (format "%s" azkae-get-project-script))))
  (let ((include-filename (concat azkae-project-dir "/.emacsproject/include_paths")))
    (if (file-exists-p include-filename)
	(let ((new-items (mapcar (lambda (item)
				   (if (not (string= (substring item 0 1) "/"))
				       (concat (concat azkae-project-dir "/") item)
				     item))
				 (split-string (get-string-from-file include-filename)))))
	  (setq azkae-custom-include-list (append azkae-custom-include-list new-items))
	  (setq azkae-include-list (append azkae-include-list new-items))
	  ))
    )
  (let ((filename (concat azkae-project-dir "/.emacsproject/cflags")))
    (if (file-exists-p filename)
	(add-to-list 'azkae-additional-cflags (replace-regexp-in-string "\n$" " "
									(get-string-from-file filename)))
      )
    )
  (message (format "Project found! %s" azkae-project-dir)))
