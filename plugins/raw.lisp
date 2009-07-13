(command
 :call-string "raw"
 :documentation "Sends the argument as a raw IRC command on this connection.  Requires admin privledges."
 :action #.(lambda (message)
	     (when-from-admin message
	       (write-sequence
		(format nil "~a~%" (command-arg "raw" message))
		(output-stream (connection message)))
	       (force-output
		(output-stream (connection message))))))