(in-package :thune)

(defcommand echo (socket message)
  (send socket (reply-to message (conf-value "nick" *conf*)
                         (command-args message))))