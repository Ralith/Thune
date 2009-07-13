(command
 :call-string "quit"
 :documentation "Quits. Requires admin privledges."
 :action #.(lambda (message)
	     (when-from-admin message
	       (quit (connection message) ""))))