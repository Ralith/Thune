(in-package :thune)

(defun send (socket message)
  (ircl:send-message socket message)
  (format t "<- ~a~%" (ircl:message->string message nil)))

(defun send-raw (socket string)
  (ircl:send-raw socket string)
  (format t "<- ~a~%" string))

(defun reply-target (message)
  "Returns the most appropriate PRIVMSG target for a reply to MESSAGE."
  (assert (slot-boundp message 'ircl:prefix))
  (let ((target (first (parameters message))))
    (if (string= target (conf-value "nick" *conf*))
	(nick (prefix message))
	target)))

(defun reply-to (message reply)
  (make-message (command message) (reply-target message) reply))

(defmacro when-from-admin (message &body body)
  `(when (some #'identity (mapcar (lambda (admin) (string= admin (prefix->string (prefix ,message))))
                                  (mapcar (lambda (str) (trim #\space str))
                                          (split-sequence:split-sequence #\, (conf-value "admins" *conf*)))))
     ,@body))

(defun sanify-output ()
  ;; If we're in SBCL but not swank, force unicode output.
  #+(and sbcl #.(cl:if (cl:find-package "SWANK") '(or) '(and)))
  (progn (setf sb-impl::*default-external-format* :UTF-8)
	 (setf sb-alien::*default-c-string-external-format* :UTF-8)
	 (sb-kernel:stream-cold-init-or-reset)))

(defun substitute-string (sequence old-pattern new-pattern)
  (let ((position (search old-pattern sequence))
        (result (copy-seq sequence)))
    (loop while position do
         (setf result
               (concatenate 'string
                            (subseq sequence 0 position)
                            new-pattern
                            (subseq sequence (+ position (length old-pattern)))))
         (setf position (search old-pattern result)))
    result))

(defun emotep (message)
  (let ((emote-prefix (format nil "~CACTION" (code-char 1)))
        (string (car (last (parameters message)))))
   (and string
        (> (length string) (length emote-prefix))
        (string= (subseq string 0 (length emote-prefix))
                 emote-prefix))))