(command
 :call-string "eval"
 :documentation "Evaluates a lisp form.  Requires admin privledges."
 :action #.(lambda (message)
	     (when-from-admin message
	       (let ((arg (command-arg "eval" message)))
		 (when arg
		   (privmsg (connection message)
			    (reply-target message)
			    (handler-case
				(remove #\newline (prin1-to-string (eval (read (make-string-input-stream arg)))))
			      (error (e) (format nil "Error: ~a" e)))))))))