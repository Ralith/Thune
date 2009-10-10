(in-package :thune)

(defcommand "reconnect" (channel message)
  "Immediately reconnects, using an optional quit message.  Admins only."
  (when-from-admin message
    (send channel (make-message "QUIT" (command-args message)))))

(defcommand "quit" (channel message)
  "Immediately quits with an optional message.  Admins only."
  (when-from-admin message
    (setf *reconnect* nil)
    (send channel (make-message "QUIT" (command-args message)))))

(defcommand "raw" (channel message)
  "Transmits the unmodified arguments directly to the IRC server.  Admins only."
  (declare (ignore channel))
  (when-from-admin message
    (send-raw *socket* (command-args message))))

(defcommand "eval" (channel message)
  "Evaluates the given expression in the bot's package.  Admins only."
  (when-from-admin message
    (send channel
          (reply-to message
                    (substitute #\\ #\Linefeed
                                (handler-case
                                    (let ((*package* (find-package :thune)))
                                      (prin1-to-string
                                       (eval (read-from-string (command-args message)))))
                                  (error (e) (format nil "Error: ~a" e))))))))