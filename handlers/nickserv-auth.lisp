(in-package :thune)

(defhandler nickserv-auth (channel message)
  (when (and (typep (prefix message) 'user)
	     (string= (conf-value 'nickserv-nick) (nick (prefix message)))
	     (string= (conf-value 'nickserv-host) (host (prefix message)))
	     (string= (conf-value 'nickserv-username) (username (prefix message)))
	     (string= (conf-value 'nickserv-challenge)
		      (second (parameters message))))
        (send channel
	      (make-message "NS"
			    (format nil "IDENTIFY ~a"
				    (conf-value 'password))))))