(in-package :thune)

(defcommand "help" (socket message)
  "Supplies documentation for a command"
  (let ((docs (documentation (find-command (command-args message)) 'function)))
    (send socket (reply-to message (if docs
                                       docs
                                       "No documentation available.")))))