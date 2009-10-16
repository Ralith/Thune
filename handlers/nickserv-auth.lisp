(in-package :thune)

(defhandler nickserv-auth (channel message)
  "Authenticates with NickServ when prompted.  Configured by a symbol:string alist with symbols NICK, HOST, USERNAME, and CHALLENGE."
  (let ((config (conf-value 'nickserv)))
    (when (and config 
               (typep (prefix message) 'user)
               (string= (cdr (assoc 'nick config))
                        (nick (prefix message)))
               (string= (cdr (assoc 'host config))
                        (host (prefix message)))
               (string= (cdr (assoc 'username config))
                        (username (prefix message)))
               (string= (cdr (assoc 'challenge config))
                        (remove-if-not #'graphic-char-p
                                       (second (parameters message)))))
      (send channel
            (make-message "NS"
                          (format nil "IDENTIFY ~a"
                                  (cdr (assoc 'password config))))))))
