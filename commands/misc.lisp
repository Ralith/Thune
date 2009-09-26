(in-package :thune)

(defcommand "ping" (socket message)
  (send socket (reply-to message "Pong!")))

(defcommand "echo" (socket message)
  (send socket (reply-to message (command-args message))))

(defcommand "zup" (socket message)
  (send socket (reply-to message "zup")))