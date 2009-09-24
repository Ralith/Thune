(in-package :thune-commands)

(defcommand ping (socket message)
  (send socket (reply-to message (conf-value "nick" *conf*) "Pong!")))

(defcommand echo (socket message)
  (send socket (reply-to message (conf-value "nick" *conf*)
                         (command-args message))))