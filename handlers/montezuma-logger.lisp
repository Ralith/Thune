(in-package :thune)

(defvar *montezuma-logs*)

(defhandler montezuma-logger (socket message)
  (declare (ignore socket))
  (unless *montezuma-logs*
    (setf *montezuma-logs*
          (make-instance 'montezuma:index
                         :path (conf-value "logpath"))))
  (let ((document))
    (cond
      ((typep (prefix message) 'user)
       (push (cons "nick" (nick (prefix message))) document)
       (push (cons "username" (username (prefix message))) document)
       (push (cons "host" (host (prefix message))) document))
      ((typep (prefix message) 'server)
       (push (cons "host" (host (prefix message))) document)))
    (push (cons "received"
                (format nil "~d" (received message))) document)
    (push (cons "command" (command message)) document)
    (loop for i from 1 for parameter in (parameters message)
         do (push (cons (format nil "parameter-~d" i)
                        parameter) document))
    (montezuma:add-document-to-index *montezuma-logs* document)))