(in-package :thune)

;;; TODO: Multiple connections

(defvar *conf* nil
  "The current Thune configuration")

(define-condition prepare-reconnect () ())

;;; Stdout logging
(defmethod irc-message-event :before (connection message)
  (format t "~a -> ~a~%" connection (raw-message-string message))
  (finish-output))

(defmethod cl-irc::send-irc-message :after (connection command &rest arguments)
  ;; make-irc-message includes a newline
  (format t "~a <- ~a" connection (apply #'cl-irc::make-irc-message command arguments))
  (finish-output))

(defun start ()
  "Launches the bot.  Should only be called once."
  ;; If we're in SBCL but not swank, force unicode output.
  #+(and sbcl #.(cl:if (cl:find-package "SWANK") '(or) '(and)))
  (progn (setf sb-impl::*default-external-format* :UTF-8)
	 (setf sb-alien::*default-c-string-external-format* :UTF-8)
	 (sb-kernel:stream-cold-init-or-reset))
  (setf *conf* (load-conf "./thune.conf"))
  (format t "Loading plugins:")
  (dolist (file (list-directory (conf-value "plugindir" *conf*)))
    (when (string-equal "lisp" (pathname-type file))
      (format t "~&~TLoading ~a..." (pathname-name file))
      (finish-output)
      (prepare-plugin
       (with-open-file (stream file)
	 (read-plugin stream)))
      (format t " done.~%")))
  (format t "Done.~%")
  (let ((reconnect t))
    (loop while reconnect do
	 (setf reconnect nil)
	 (let ((connection (connect
			    :nickname (conf-value "nick" *conf*)
			    :server (conf-value "server" *conf*))))
	   ;; Silence UNHANDLED-EVENT, etc
	   (setf (client-stream connection) (make-broadcast-stream))
	   (init-plugin-system connection)
	   (dolist (plugin *plugins*)
	     (load-plugin plugin connection))
	   (handler-bind ((no-such-reply #'continue)
			  (prepare-reconnect #'(lambda (s)
						 (declare (ignore s))
						 (setf reconnect t)))
			  (error #'(lambda (e)
				     (quit connection
					   (format nil "Encountered an unhandled error: ~a" e))
				     (continue e))))
	     (read-message-loop connection)
	     (cleanup-plugin-system connection))))))