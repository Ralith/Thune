(plugin
 :name "nickserv"
 :hooks (irc-notice-message)		;privmsg too?
 :action #.(lambda (message)
	     (when (and
		    (string=
		     (conf-value "nsnick" *conf*)
		     (source message))
		    (string=
		     (conf-value "nshost" *conf*)
		     (host message))
		    (string=
		     (conf-value "nsuser" *conf*)
		     (user message))
		    (string=
		     (conf-value "nsmsg" *conf*)
		     (car (last (arguments message)))))
	       (privmsg (connection message)
			(source message)
			(concatenate
			 'string
			 "IDENTIFY "
			 (conf-value "nspass" *conf*))))))