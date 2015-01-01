;; Some simple emacs settings

;; Set default window size in gui mode - customized for i3
(add-to-list 'default-frame-alist '(width . 93)) ; character
(add-to-list 'default-frame-alist '(height . 42)) ; lines

;; Change time display
(setq display-time-day-and-date t
      display-time-24hr-format t)
(display-time)

;; Remove startup message
(setq inhibit-startup-message t)

;; @TODO
(setq c-toggle-auto-newline)

;; Automatic indent on Enter key
(global-set-key (kbd "RET") 'newline-and-indent) 

;; desactivate yes-or-no question => replace it with y-or-n. Much faster
(defalias 'yes-or-no-p 'y-or-n-p)

(kill-buffer "*scratch*")

;; Setup buffer name to be more clear
(require 'uniquify)
(require 'cl)

(defun skip-buffers (buffer-list func)
  (loop for dummy in buffer-list do
	(loop for buffer in buffer-list do
	      (when (string= buffer (buffer-name))
		(funcall func)
	      ))
  ))

(defvar skip-buffer-list '("*Messages*" "*clang-complete*"))

;; @TODO: improve, not only for message?
(defun my-next-buffer ()
  "next-buffer, only skip *Messages*"
  (interactive)
  (next-buffer)
  (skip-buffers skip-buffer-list 'next-buffer))

(defun my-prev-buffer ()
  "prev-buffer, only skip *Messages*"
  (interactive)
  (previous-buffer)
  (skip-buffers skip-buffer-list 'previous-buffer))

(global-set-key [remap next-buffer] 'my-next-buffer)
(global-set-key [remap previous-buffer] 'my-prev-buffer)

;; Setup paren mode
(require 'paren)
(show-paren-mode)

;; Set delete-selection-mode
(delete-selection-mode)

;; Stop making annoying ~ files
(setq make-backup-files nil)

(defun my-delete-trailing-blank-lines ()
  "Deletes all blank lines at the end of the file."
  (interactive)
  (save-excursion
    (save-restriction
      (widen)
      (goto-char (point-max))
      (delete-blank-lines))))

;; Cleanup file when saving
(add-hook 'before-save-hook 'my-delete-trailing-blank-lines)
(add-hook 'c-mode-hook '(lambda () (add-hook 'write-contents-hooks 'delete-trailing-whitespace nil t)))
(add-hook 'c++-mode-hook '(lambda () (add-hook 'write-contents-hooks 'delete-trailing-whitespace nil t)))

;; Treat underscore like a part of a word
(add-hook 'c-mode-hook
	  (lambda () (modify-syntax-entry ?_ "w")))
(add-hook 'c++-mode-hook
	  (lambda () (modify-syntax-entry ?_ "w")))
(add-hook 'makefile-mode-hook
	  (lambda () (modify-syntax-entry ?_ "w")))
(add-hook 'makefile-mode-hook
	  (lambda () (modify-syntax-entry ?_ "w")))

;; Select lines
(global-set-key (kbd "C-f") "\C-a\C-@\C-e")
