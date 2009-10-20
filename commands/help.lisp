(in-package :thune)

(defcommand "help" (channel message)
  "Supplies documentation for a command"
  (send channel
        (reply-to
         message
         (let ((args (command-args message)))
           (if (> (length args) 0)
               (let ((docs (documentation (or (find-command args)
                                              (find-command (alias-target args)))
                                          'function)))
                 (if docs docs
                     "No documentation found."))
               ;; Note: Format iterator yoinked from PCL
               (format nil "Available commands: ~{~#[~;~a~;~a and ~a~:;~@{~a~#[~;, and ~:;, ~]~}~]~}.  Call help on individual commands for more information."
                       (mapcar #'car *commands*)))))))

(defcommand "aliases" (channel message)
  "Lists all aliases and their targets."
  (send channel
        (reply-to message
                  ;; Note: Format iterator yoinked from PCL
                  (format nil "Aliases: ~{~#[~;~a~;~a and ~a~:;~@{~a~#[~;, and ~:;, ~]~}~]~}."
                          (mapcar (lambda (alias)
                                    (format nil "~a:~a" (car alias) (cdr alias)))
                                  *aliases*)))))
