(in-package :thune)

(defvar *channel-indices* nil)

(defun channel-index (channel)
  (cdr (assoc channel *channel-indices* :test #'string-equal)))

(defhandler montezuma-logger (socket message)
  (declare (ignore socket))
  (let* ((channel (first (parameters message)))
         (index (channel-index channel))
         (document))
    (when (and (some (lambda (x) (string-equal (command message) x))
                     '("PRIVMSG" "NOTICE" "PART"))
               (char= #\# (aref channel 0)))
     (unless index
       (let ((new-index (make-instance 'montezuma:index
                                          :path
                                          (format nil "~a/~a"
                                                  (conf-value 'logpath)
                                                  channel))))
         (push (cons channel new-index) *channel-indices*)
         (setf index new-index)))
     (when (prefix message)
       (when (typep (prefix message) 'user)
         (push (cons "nick" (nick (prefix message))) document)
         (push (cons "username" (username (prefix message))) document))
       (push (cons "host" (host (prefix message))) document))
     (push (cons "received"
                 (format nil "~d" (received message))) document)
     (push (cons "command" (command message)) document)
     (loop for i from 1 for parameter in (parameters message)
        do (push (cons (format nil "parameter-~d" i)
                       parameter) document))
     (montezuma:add-document-to-index index document))))