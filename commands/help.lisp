(in-package :thune)

(defcommand "help" (channel message)
  "Supplies documentation for a command"
  (send channel
        (reply-to
         message
         (let ((args (command-args message)))
           (if (> (length args) 0)
               (let ((docs (documentation (find-command args) 'function)))
                 (if docs docs
                     "No documentation found."))
               ;; Note: Format iterator yoinked from PCL
               (format nil "Available commands: ~{~#[~;~a~;~a and ~a~:;~@{~a~#[~;, and ~:;, ~]~}~]~}.  Call help on individual commands for more information."
                       (mapcar #'car *commands*)))))))