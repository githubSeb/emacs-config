;; See http://stackoverflow.com/questions/8549351/c11-mode-or-settings-for-emacs
(require 'font-lock)

(defun --copy-face (new-face face)
  "Define NEW-FACE from existing FACE."
  (copy-face face new-face)
  (eval `(defvar ,new-face nil))
  (set new-face new-face))

(--copy-face 'font-lock-doc-markup-face ; comment markups such as Javadoc-tags
         'font-lock-doc-face)
(--copy-face 'font-lock-doc-string-face ; comment markups
         'font-lock-comment-face)

(global-font-lock-mode t)
(setq font-lock-maximum-decoration t)


(add-hook 'c++-mode-hook
      '(lambda()
        (font-lock-add-keywords
         nil '(;; complete some fundamental keywords
           ("\\<\\(void\\|unsigned\\|signed\\|char\\|short\\|bool\\|int\\|long\\|float\\|double\\)\\>" . font-lock-keyword-face)
           ;; add the new C++11 keywords
           ("\\<\\(alignof\\|alignas\\|constexpr\\|decltype\\|noexcept\\|nullptr\\|static_assert\\|thread_local\\|override\\|final\\)\\>" . font-lock-keyword-face)
           ("\\<\\(char[0-9]+_t\\)\\>" . font-lock-keyword-face)
           ;; PREPROCESSOR_CONSTANT
           ("\\<[A-Z]+[A-Z_]+\\>" . font-lock-constant-face)
           ;; hexadecimal numbers
           ("\\<0[xX][0-9A-Fa-f]+\\>" . font-lock-constant-face)
           ;; integer/float/scientific numbers
	   ("\\<[-+]?[0-9]*\\.?[0-9]*\\([uUlL]+\\|[eE][-+]?[0-9]+\\)?[fFlL]?\\>" . font-lock-constant-face)
           ;; user-types (customize!)
           ;; ("\\<[A-Za-z_]+[A-Za-z_0-9]*_\\(t\\|type\\|ptr\\)\\>" . font-lock-type-face)
           ;; ("\\<\\(xstring\\|xchar\\)\\>" . font-lock-type-face)
           ))
        ) t)

;; Remove indent in namespace
(c-set-offset 'innamespace 0)

(defadvice c-lineup-arglist (around my activate)
  "Improve indentation of continued C++11 lambda function opened as argument."
  (setq ad-return-value
        (if (and (equal major-mode 'c++-mode)
                 (ignore-errors
                   (save-excursion
                     (goto-char (c-langelem-pos langelem))
                     ;; Detect "[...](" or "[...]{". preceded by "," or "(",
                     ;;   and with unclosed brace.
                     (looking-at ".*[(,][ \t]*\\[[^]]*\\][ \t]*[({][^}]*$"))))
            0                           ; no additional indent
          ad-do-it)))                   ; default behavior
