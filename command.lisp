(in-package :thune)

(defclass command (plugin)
  ((name
    :initform nil
    :reader command-name)
   (call-string
    :initarg :call-string
    :initform (error "Commands must have a call-string!")
    :reader command-call-string
    :documentation "Unique identifier that may be used in IRC to call ACTION.")
   (hooks
    :initform '(irc-privmsg-message irc-notice-message))
   (action
    :accessor command-action)
   (documentation
    :initarg :documentation
    :initform "This command is undocumented."
    :reader command-documentation)))

(defmethod initialize-instance :after ((command command) &key)
  (when (null (command-name command))
    (setf (slot-value command 'name) (command-call-string command))))

(defmethod run-plugin ((command command) message)
  (let* ((name (command-name command))
	 (namelen (length name))
	 (text (second (arguments message)))
	 (txtlen (1- (length text))))
    (when (and (or (= txtlen namelen)
		   (and (>= txtlen namelen)
			(char= #\space (char text (1+ namelen)))))
	       (char= (char (conf-value "cmdchar" *conf*) 0)
		      (char text 0))
	       (string-equal name (subseq text 1 (1+ namelen))))
      (funcall (command-action command) message))))

(defun command-arg (name message)
  (let ((start (+ 2 (length name)))
	(text (second (arguments message))))
    (if (> (length text) start)
	(subseq text start)
	nil)))