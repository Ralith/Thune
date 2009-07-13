(plugin
 :name "stdout-log"
 :hooks (irc-message)
 :action #.(lambda (message)
	     (format t "<- ~a" (raw-message-string message))))