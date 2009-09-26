(in-package :thune)

(defcommand "ping" (socket message)
  "Instantly replies with \"Pong!\""
  (send socket (reply-to message "Pong!")))

(defcommand "echo" (socket message)
  "Sends the arguments back to the message's origin."
  (send socket (reply-to message (command-args message))))

(defcommand "zup" (socket message)
  "zup"
  (send socket (reply-to message "zup")))

(defcommand "emote" (socket message)
  "Performs an emote of the arguments."
  (send socket (reply-to message (format nil "~CACTION ~a~C"
                                         (code-char 1)
                                         (command-args message)
                                         (code-char 1)))))
