(command
 :call-string "newcmd"
 :documentation "Creates a new command whose name is the first argument and whose action is the second."
 :action #.(lambda (message)
	     (when-from-admin message
	       (let* ((arg (command-arg "newcmd" message))
		      (split (position #\space arg))
		      (name (subseq arg 0 split))
		      (funcstr (subseq arg (1+ split)))
		      (errstream (make-string-output-stream))
		      (func (handler-case
				(eval (let ((*package* (find-package :thune)))
					(read (make-string-input-stream funcstr))))
			      (error (e) (progn
					   (princ "ERROR: " errstream)
					   (princ e errstream)
					   nil)))))
		 (if func
		     (let ((msg (make-string-output-stream))
			   (plugin))
		       (setf plugin
			     (make-instance 'command
					    :call-string name
					    :action func))
		       (handler-case
			   (prepare-plugin plugin)
			 (plugin-exists () (princ "WARNING: Overriding a previous plugin definition. " msg)))
		       (load-plugin plugin (connection message))
		       (princ "Success." msg)
		       (reply-to message
				 (get-output-stream-string msg)))
		     (reply-to message
			       (get-output-stream-string errstream)))))))