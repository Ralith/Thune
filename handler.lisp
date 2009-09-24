(in-package :thune)

(defvar *handlers* ())

(defun add-handler (handler)
  (pushnew handler *handlers*))

(defmacro defhandler (name args &body body)
  `(progn
     (defun ,name ,args ,@body)
     (add-handler (quote ,name))))

(defun call-handlers (socket message)
  (mapcar (lambda (handler)
            (funcall handler socket message))
          *handlers*))