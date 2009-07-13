(command
 :call-string "list-cmds"
 :documentation "Lists the names of all currently loaded commands."
 :action (lambda (message)
	   (reply-to message
		     (apply #'concatenate
			    'string
			    (mapcar
			     (lambda (cmd)
			       (concatenate 'string
					    (command-name cmd)
					    " "))
			     (remove-if-not (instance-of 'command)
					    *plugins*))))))