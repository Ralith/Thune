(in-package :thune)

(defvar *handlers* ())

(defun add-handler (handler &optional allow-duplicates)
  (unless (and (not allow-duplicates)
               (some (lambda (x) (eq handler x)) *handlers*))
    (pushnew handler *handlers*)))

(defmacro defhandler (name args &body body)
  `(progn
     (defun ,name ,args ,@body)
     (add-handler (quote ,name))))