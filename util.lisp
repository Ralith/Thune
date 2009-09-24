(in-package :thune)

(defun send (socket message)
  (send-message socket message)
  (format t "<- ~a~%" (message->string message nil)))

(defun reply-target (message nick)
  "Returns the most appropriate PRIVMSG target for a reply to MESSAGE."
  (assert (slot-boundp message 'ircl:prefix))
  (let ((target (first (parameters message))))
    (if (string= target nick)
	(nick (prefix message))
	target)))

(defun reply-to (message nick reply)
  (make-message (command message) (list (reply-target message nick)
                                        reply)))

(defmacro when-from-admin (message &body body)
  `(when (some #'identity (mapcar (lambda (admin) (string= admin (host ,message)))
                                  (mapcar (lambda (str) (trim #\space str))
                                          (split-sequence:split-sequence #\, (conf-value "admins" *conf*)))))
     ,@body))

(defun sanify-output ()
  ;; If we're in SBCL but not swank, force unicode output.
  #+(and sbcl #.(cl:if (cl:find-package "SWANK") '(or) '(and)))
  (progn (setf sb-impl::*default-external-format* :UTF-8)
	 (setf sb-alien::*default-c-string-external-format* :UTF-8)
	 (sb-kernel:stream-cold-init-or-reset)))