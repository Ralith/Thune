(in-package :thune)

(defcommand "quit" (socket message)
  (when-from-admin message
   (send socket (make-message "QUIT" (list (command-args message))))))