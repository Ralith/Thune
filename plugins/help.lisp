(command
 :call-string "help"
 :documentation "Responds with the documentation for the command named in the argument."
 :action #.(lambda (message)
	     (let ((arg (command-arg "eval" message)))
	       (when arg
		 (let ((plugin (car (remove-if-not
				     (lambda (plugin)
				       (and (eq (find-class 'command) (class-of plugin))
					    (string-equal arg (command-name plugin)))) *plugins*))))
		   (reply-to message
			     (if plugin
				 (command-documentation plugin)
				 "No such command!")))))))