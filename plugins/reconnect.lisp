(command
 :call-string "reconnect"
 :documentation "Quits and immediately reconnects. Requires admin privledges."
 :action #.(lambda (message)
	     (when-from-admin message
	       (signal 'prepare-reconnect)
	       (quit (connection message) "Reconnecting"))))