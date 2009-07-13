(command
 :call-string "ping"
 :documentation "Responds with \"Pong!\"; useful for testing the connectivity of the bot or your own client."
 :action #.(lambda (message)
	     (reply-to message "Pong!")))