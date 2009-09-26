(in-package :thune)

(defcommand "reconnect" (socket message)
  (when-from-admin message
    (send socket (make-message "QUIT" (command-args message)))))

(defcommand "quit" (socket message)
  (when-from-admin message
    (signal 'disable-reconnect)
    (send socket (make-message "QUIT" (command-args message)))))

(defcommand "raw" (socket message)
  (when-from-admin message
    (send-raw socket (command-args message))))

(defcommand "eval" (socket message)
  (when-from-admin message
    (send socket (reply-to message
                           (handler-case
                               (let ((*package* (find-package :thune)))
                                 (prin1-to-string
                                  (eval (read-from-string (command-args message)))))
                             (error (e) (format nil "Error: ~a" e)))))))