;; Setup git-gutter-fringe+

(conf:add-to-path "git-gutter-fringe")

(require 'git-gutter-fringe+)
(git-gutter-fr+-minimal)
(global-git-gutter+-mode)
