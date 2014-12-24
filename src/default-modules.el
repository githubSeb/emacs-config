;; Load confing modules
;; If you which to use your own module loader (not linked with git) please create custom-modules.el:
;; cp default-modules.el custom-modules.el
;; custom-modules will then be used instead of this file.

(conf:load-module "emacs-settings")

(conf:load-module "auto-complete")
(conf:load-module "auto-complete-clang-async")
(conf:load-module "autopair")
(conf:load-module "basic-keybindings")
(conf:load-module "better-cc-mode")
(conf:load-module "cycle-buffer")
(conf:load-module "duplicate-region")
(conf:load-module "git-gutter-fringe")
(conf:load-module "highlight-symbol")
(conf:load-module "ido")
(conf:load-module "multiple-cursors")
(conf:load-module "smooth-scroll")
(conf:load-module "tags")
(conf:load-module "undo-tree")
(conf:load-module "window")
(conf:load-module "yasnippet")
(conf:load-module "updater")
