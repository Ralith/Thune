(in-package :thune)

(defcommand "ping" (socket message)
  (send socket (reply-to message "Pong!")))

(defcommand "echo" (socket message)
  (send socket (reply-to message (command-args message))))

(defcommand "zup" (socket message)
  (send socket (reply-to message "zup")))

(defcommand "emote" (socket message)
  (sfend socket (reply-to message (format nil "~CACTION ~a~C"
                                         (code-char 1)
                                         (command-args message)
                                         (code-char 1)))))
