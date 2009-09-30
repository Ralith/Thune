(in-package :thune)

(defcommand "help" (socket message)
  "Supplies documentation for a command"
  (send socket
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