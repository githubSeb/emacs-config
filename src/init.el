;; Conf startup file

(require 'cl)

(defvar conf:default-directory default-directory
  "Default directory. May be changed by modules.")

(defvar conf:root-path (file-name-directory load-file-name)
  "Root path of conf directory")

(defun conf:load-file(file-name)
  "Load a file if it exists"
  (let ((full-file-name (format "%s/%s" conf:root-path file-name)))
    (if (file-exists-p full-file-name)
	(progn (load-file full-file-name)
	       t)
      (message (format "File %s not found" file-name))
      nil)))

(defun conf:load-module(module-name)
  "Load a module if it exists"
  (let ((full-module-name (format "%s/%s/init.el" conf:root-path module-name)))
    (if (file-exists-p full-module-name)
	(progn
	  (let ((except-value
		 (catch 'load-module-exception
		   (load-file full-module-name)
		   nil)))
	    (if except-value
		(message (format "Unable to load %s module: %s" module-name except-value)))
	    ))
      (message (format "Module %s not found" module-name)))))

(defun conf:add-to-path(&optional path &optional load-list)
  "Add path to the load-path"
  (if (not path)
      (setq path ""))
  (if (not load-list)
      (setq load-list 'load-path))
  (let ((full-module-name (format "%s/%s" (file-name-directory load-file-name) path)))
    (add-to-list load-list full-module-name)))

(defun conf:require(require-list &optional no-throw)
  "Ensure that require-list is provided. Throw 'load-module-exception if a package is not found"
  (let ((except-value
	 (catch 'load-module-exception
	   (loop for value in require-list do
		 (when (not (require value nil 'noerror))
		   (throw 'load-module-exception (format "%s is not provided" value))))
	   nil)))
    (if (and except-value (not no-throw))
    	(throw 'load-module-exception except-value))
    (not except-value)))

(if (not (conf:load-file "custom-modules.el"))
    (conf:load-file "default-modules.el"))
