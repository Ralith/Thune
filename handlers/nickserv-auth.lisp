(in-package :thune)

(defhandler nickserv-auth (channel message)
  (when (and (typep (prefix message) 'user)
	     (string= "NickServ" (nick (prefix message)))
	     (string= "esper.net" (host (prefix message)))
	     (string= "services" (username (prefix message)))
	     (string= (format nil
			      "This nickname is registered and protected.  If it is your nickname, type ~a/msg NickServ IDENTIFY ~apassword~a~a.  Otherwise, please choose a different nickname."
			      (code-char 2)
			      (code-char 31)
			      (code-char 31)
			      (code-char 2))
		      (second (parameters message))))
        (send channel
	      (make-message "NS"
			    (format nil "identify ~a"
				    (conf-value 'password))))))