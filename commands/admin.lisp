(in-package :thune)

(defcommand "reconnect" (socket message)
  (when-from-admin message
    (send socket (make-message "QUIT" (list (command-args message))))))

(defcommand "quit" (socket message)
  (when-from-admin message
    (signal 'disable-reconnect)
    (send socket (make-message "QUIT" (list (command-args message))))))