(in-package :thune)

(defhandler revenge (channel message)
  (let ((string (car (last (parameters message)))))
    (when (and (emotep message)
               (search (conf-value 'nick) string))
      (send channel (reply-to message (substitute-string string
                                                         (conf-value 'nick) (nick (prefix message))))))))