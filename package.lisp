(defpackage :thune
  (:use :cl :ircl :cl-fad :split-sequence)
  (:documentation "An IRC bot")
  (:export
   :start
   :defcommand :add-command :command-args
   :send :reply-to :conf-value
   :*conf*))