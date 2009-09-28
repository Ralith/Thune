(in-package :thune)

(defhandler revenge (socket message)
  (let ((string (car (last (parameters message)))))
    (when (and (emotep message)
               (search (conf-value "nick" *conf*) string))
      (send socket (reply-to message (substitute-string string
                                                        (conf-value "nick" *conf*) (nick (prefix message))))))))