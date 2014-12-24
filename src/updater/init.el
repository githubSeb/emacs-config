;; Config updater

(defvar checkout-period 302400
  "Update checkout period is 3 days")

(defvar last-update-file (format "%s/last-update" (file-name-directory load-file-name)))

(defun updater--get-string-from-file (filePath)
  "Return filePath's file content."
  (with-temp-buffer
    (insert-file-contents filePath)
    (buffer-string)))

(defun conf:update (result)
  (interactive (list (y-or-n-p "Would you like to check for config update?")))
  (if result
      (progn
	(message "Updating..")
	(compile (format "cd %s/..; git fetch; if [ `git rev-list HEAD...origin/master --count` != 0 ]; then; git pull && ./install; else; echo 'Already up to date'; fi; cd -" conf:root-path)))
    (message "You can run conf:update if you which to update later.")))

(defun updater--write-new-time ()
  (with-temp-file last-update-file
    (insert (number-to-string (truncate (float-time))))))

(defun conf:verify-update ()
  (if (not (file-exists-p last-update-file))
      (updater--write-new-time)
    (progn
      (let ((old-time (string-to-number (updater--get-string-from-file last-update-file)))
	    (current-time (truncate (float-time))))
	(if (> (- current-time old-time) checkout-period)
	    (progn (call-interactively 'conf:update)
		   (updater--write-new-time)))
	))))

(conf:verify-update)
