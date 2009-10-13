(in-package :thune)

(defvar *channel-indices* nil)

(defun channel-index (channel)
  (cdr (assoc channel *channel-indices* :test #'string-equal)))

;;; TODO: Log messages to a real database, keyed on mz doc-numbers
(defhandler fts-logger (socket message)
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
     (when (typep (prefix message) 'user)
       (push (cons "nick" (nick (prefix message))) document))
     (push (cons "message" (second (parameters message))) document)
     (montezuma:add-document-to-index index document))))