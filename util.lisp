(in-package :thune)

(defun send (socket message)
  (ircl:send-message socket message)
  (format t "<- ~a~%" (ircl:message->string message nil)))

(defun send-raw (socket string)
  (ircl:send-raw socket string)
  (format t "<- ~a~%" string))

(defun reply-target (message)
  "Returns the most appropriate PRIVMSG target for a reply to MESSAGE."
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
  (let ((string (car (last (parameters message))))
        (end (1+ (length "ACTION"))))
    (and (ctcpp message)
         string
         (> (length string) end)
         (string= (subseq string 1 end)
                  "ACTION"))))

(defun ctcpp (message)
  (let ((string (car (last (parameters message)))))
    (when (> (length string) 0)
      (char= (code-char 1) (aref string 0)))))

(defun month-name (number)
  (case number
    (1 "January")
    (2 "February")
    (3 "March")
    (4 "April")
    (5 "May")
    (6 "June")
    (7 "July")
    (8 "August")
    (9 "September")
    (10 "October")
    (11 "November")
    (12 "December")))

(defun format-time (time &optional (time-zone 0))
  (multiple-value-bind (seconds minutes hours date month year)
      (decode-universal-time time time-zone)
    (format nil "~a:~a:~a GMT on the ~a of ~a, ~a"
            hours minutes seconds date (month-name month) year)))