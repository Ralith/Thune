(load "loader.lisp")
(sb-ext:save-lisp-and-die "thune" :executable t :toplevel #'thune:start :purify t)
