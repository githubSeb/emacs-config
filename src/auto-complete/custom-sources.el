(require 'auto-complete)

;; Filename source
(defvar ac-filename-cache-current nil)

;; --------------------INCLUDE SYSTEM FILE START-----------------------------

;; (let ((files (directory-files dir nil "^[^.]")))
;; AZKAE
(defun ac-filename-candidate-current (current-path)
  (ignore-errors
    (string-match "\"\\(.*\\)\"?" ac-prefix)
    (setq azkae-full-path-to-current-dir (concat current-path "/"))
    (setq azkae-prefix (concat azkae-full-path-to-current-dir (match-string 1 ac-prefix)))
    (setq azkae-prefix-full-path-to-dir (file-name-directory azkae-prefix))
    (setq azkae-prefix-files (directory-files azkae-prefix-full-path-to-dir nil "^[^.]"))
    (string-match "\\( *\\|	*\\)include\\( *\\|	*\\)\"" ac-prefix)
    (setq azkae-include-prefix (match-string 0 ac-prefix))
    (unless (file-regular-p azkae-prefix)
      (loop for file in azkae-prefix-files
            for full_path = (concat azkae-prefix-full-path-to-dir file)
	    for path = (concat azkae-include-prefix (substring full_path (length azkae-full-path-to-current-dir) nil))
	    when (or (string-match ".*\\(h\\|hh\\|hpp\\|inc\\)$" file)
		     (file-directory-p full_path))
            collect (if (file-directory-p full_path)
			(concat path "/")
		      path)
;;	    do (print full_path)
	    ))
    )
  )

(defun ac-filename-candidate-current-file ()
  (if (not (equal ac-filename-cache-current nil))
      ac-filename-cache-current
    (setq azkae-list (ac-filename-candidate-current (file-name-directory (buffer-file-name))))
    (loop for path in azkae-custom-include-list
	do (setq azkae-list (append azkae-list (ac-filename-candidate-current path)))
	)
    (setq ac-filename-cache-current azkae-list)
    azkae-list))

;; Files in current directory source
(defvar ac-sources-include-files-in-current-dir
  '((init . (setq ac-filename-cache-current nil))
    (candidates . ac-filename-candidate-current-file)
    (prefix . "#\\( *\\|	*\\)include\\( *\\|	*\\)\"\\(.*\\)")
    (requires . 0)
    (action . ac-start)
    (limit . nil)))

(ac-define-source files-in-current-dir
    '((candidates . (directory-files default-directory))
          (cache)))

;; --------------------INCLUDE SYSTEM FILE START-----------------------------

(defun ac-filename-candidate-current-system (system-path)
  (ignore-errors
  (string-match "<\\(.*\\)>?" ac-prefix)
  (setq azkae-full-path-to-current-dir (concat system-path "/"))
  (setq azkae-prefix (concat azkae-full-path-to-current-dir (match-string 1 ac-prefix)))
  (setq azkae-prefix-full-path-to-dir (file-name-directory azkae-prefix))
  (setq azkae-prefix-files (directory-files azkae-prefix-full-path-to-dir nil "^[^.]"))
  (string-match "\\( *\\|	*\\)include\\( *\\|	*\\)<" ac-prefix)
  (setq azkae-include-prefix (match-string 0 ac-prefix))
  (unless (file-regular-p azkae-prefix)
      (loop for file in azkae-prefix-files
            for full_path = (concat azkae-prefix-full-path-to-dir file)
	    for path = (concat azkae-include-prefix (substring full_path (length azkae-full-path-to-current-dir) nil))
;;	    when (string-match ".*\\(h\\|hh\\|hpp\\|inc\\)" file)
            collect (if (file-directory-p full_path)
			(concat path "/")
		      (concat path ">"))
;;	    do (print full_path)
	    ))
    )
  )

(defun ac-filename-candidate-current-system-call ()
  (if (not (equal ac-filename-cache-system nil))
      ac-filename-cache-system
    (setq azkae-list ())
    (loop for path in azkae-include-list
	  do (setq azkae-list (append azkae-list (ac-filename-candidate-current-system path)))
	  )
    (setq ac-filename-cache-system azkae-list)
    azkae-list))

(defvar ac-filename-cache-system nil)

;; Files in system directory source
(defvar ac-sources-files-system
  '((init . (setq ac-filename-cache-system nil))
    (candidates . ac-filename-candidate-current-system-call)
    (prefix . "#\\( *\\|	*\\)include\\( *\\|	*\\)<\\(.*\\)")
    (requires . 0)
    (action . ac-start)
    (limit . nil)))

;; --------------------INCLUDE SYSTEM FILE END-----------------------------

;; Filename source
(defvar ac-filename-cache nil)

(defun ac-filename-candidate ()
  (unless (file-regular-p ac-prefix)
    (ignore-errors
      (loop with dir = (file-name-directory ac-prefix)
            with files = (or (assoc-default dir ac-filename-cache)
                             (let ((files (directory-files dir nil "^[^.]")))
                               (push (cons dir files) ac-filename-cache)
                               files))
            for file in files
            for path = (concat dir file)
            collect (if (file-directory-p path)
                        (concat path "/")
                      path)))))

(ac-define-source filename
  '((init . (setq ac-filename-cache nil))
    (candidates . ac-filename-candidate)
    (prefix . valid-file)
    (requires . 0)
    (action . ac-start)
    (limit . nil)))

;; --------------------------MAKEFILE SOURCES-----------------------------

;; Azkae - Make makefile (ahah) autocomplete file name in current directory

(defun ac-makefile-filename-candidate-current ()
  (ignore-errors
    (setq azkae-full-path-to-current-dir (file-name-directory (buffer-file-name)))
    (setq azkae-prefix (concat azkae-full-path-to-current-dir ac-prefix))
    (setq azkae-prefix-full-path-to-dir (file-name-directory azkae-prefix))
    (setq azkae-prefix-files (directory-files azkae-prefix-full-path-to-dir nil "^[^.]"))
    (unless (file-regular-p azkae-prefix)
      (loop for file in azkae-prefix-files
            for full_path = (concat azkae-prefix-full-path-to-dir file)
	    for path = (substring full_path (length azkae-full-path-to-current-dir) nil)
	    when (or (string-match ".*\\(c\\|cpp\\|cc\\)$" file)
		     (file-directory-p full_path))
            collect (if (file-directory-p full_path)
			(concat path "/")
		      path)
;;	    do (print path)
	    ))
    )
  )

(defvar ac-filename-cache-makefile nil)

;; Files in current directory source
(defvar ac-source-makefile-current-dir
  '((init . (setq ac-filename-cache-makefile nil))
    (candidates . ac-makefile-filename-candidate-current)
    (requires . 0)
    (action . ac-start)
))

(defun ac-makefile-rules-candidate()
  (setq azkae-makefile-list-rules ())
  (setq azkae-makefile-line-number (line-number-at-pos (point)))
  (save-excursion
    (beginning-of-buffer)
    (setq azkae-makefile-parse-line t)
    (while azkae-makefile-parse-line
      (if (and (not (equal (thing-at-point 'word) nil))
	       (not (equal (line-number-at-pos (point)) azkae-makefile-line-number)))
	  (add-to-list 'azkae-makefile-list-rules (thing-at-point 'word))
	)
      (setq azkae-makefile-parse-line (= 0 (forward-line 1)))
      )
    )
  azkae-makefile-list-rules
  )

(defvar ac-filename-cache-makefilerule nil)

(defvar ac-source-makefile-rules
  '((init . (setq ac-filename-cache-makefilerule nil))
    (candidates . ac-makefile-rules-candidate)
    (requires . 0)
))

(provide 'custom-sources)
