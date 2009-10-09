(in-package :thune)

(defvar *handlers* ())

(defun add-handler (handler)
  (pushnew handler *handlers*))

(defun remove-handler (handler)
  (setf *handlers* (remove handler *handlers*)))

(defmacro defhandler (name args &body body)
  `(progn
     (defun ,name ,args ,@body)
     (add-handler (quote ,name))))

(defun call-handlers (channel message)
  (mapcar (lambda (handler)
            (pexec () (funcall handler channel message)))
          *handlers*))