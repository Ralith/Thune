(in-package :thune)

(defcommand "ping" (channel message)
  "Instantly replies with \"Pong!\""
  (send channel (reply-to message "Pong!")))

(defcommand "echo" (channel message)
  "Sends the arguments back to the message's origin."
  (send channel (reply-to message (command-args message))))

(defcommand "zup" (channel message)
  "zup"
  (send channel (reply-to message "zup")))

(defcommand "emote" (channel message)
  "Performs an emote of the arguments."
  (send channel (reply-to message (format nil "~CACTION ~a~C"
                                          (code-char 1)
                                          (command-args message)
                                          (code-char 1)))))

(defcommand "uptime" (channel message)
  (send channel (reply-to message (format-interval (- (get-universal-time)
                                                      *start-time*)))))
