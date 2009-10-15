(in-package :thune)

(defvar *handlers* ()
  "List of function specifiers to handle each message.")

(defun add-handler (handler)
  "Configures a function specifier HANDLER for use.  If the given function specifier has already been configured, does nothing."
  (pushnew handler *handlers*))

(defun remove-handler (handler)
  "Disables function specifier HANDLER acting as a message handler."
  (setf *handlers* (remove handler *handlers*)))

(defmacro defhandler (name args &body body)
  "Defines and configures for use a new handler."
  `(progn
     (defun ,name ,args ,@body)
     (add-handler (quote ,name))))

(defun call-handlers (channel message)
  "Spawns all handlers on MESSAGE."
  (mapcar (lambda (handler)
            (pexec (:name (format nil "Transient Handler: ~a" handler))
              (funcall handler channel message)))
          *handlers*))