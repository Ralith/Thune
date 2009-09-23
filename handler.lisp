(in-package :thune)

(defvar *handlers* ())

(defun add-handler (handler)
  (pushnew handler *handlers*))

(defmacro defhandler (name args &body body)
  `(progn
     (defun ,name ,args ,@body)
     (add-handler (quote ,name))))