(in-package :thune)

(defun trim (c str)
  "Trims all instances of C from both ends of STR.  Returns a subsequence of STR."
  (let* ((len (length str))
	 (start 0) (end len))
    (do ((i 0 (1+ i)))
	((char/= c (char str i)))
      (setf start (1+ i)))
    (do ((i  (1- len) (1- i)))
	((char/= c (char str i)))
      (setf end i))
    (subseq str start end)))

(defun reply-target (message)
  "Returns the most appropriate PRIVMSG target for a reply to MESSAGE."
  (let ((target (first (arguments message))))
    (if (equal target
	       (nickname (user (connection message))))
	(source message)
	target)))

(define-condition unable-to-reply (warning) ())

(defun reply-to (message reply)
  (let ((connection (connection message))
	(target (reply-target message))
	(command (command message)))
    (cond
      ((string-equal command "privmsg")
       (privmsg connection target reply))
      ((string-equal command "notice")
       (notice connection target reply))
      (t (warn 'unable-to-reply)))))

(defmacro when-from-admin (message &body body)
  `(when (some #'identity (mapcar (lambda (admin) (string= admin (host ,message)))
			       (mapcar (lambda (str) (trim #\space str))
				       (split-sequence:split-sequence #\, (conf-value "admins" *conf*)))))
     ,@body))

(defun eq-to (value)
  (lambda (other) (eq other value)))

(defun instance-of (class-name)
  (compile 'nil `(lambda (x) (typep x ',class-name))))

