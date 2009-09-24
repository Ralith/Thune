(in-package :thune)

(defcommand echo (socket message)
  (let ((args (command-args message)))
    (send socket (reply-to message (conf-value "nick" *conf*)
                           (if args
                               args
                               "echo")))))