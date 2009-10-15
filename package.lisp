(defpackage :thune
  (:use :cl :ircl :cl-fad :split-sequence :chanl)
  (:shadow :send-raw)
  (:documentation "An IRC bot")
  (:export :start))