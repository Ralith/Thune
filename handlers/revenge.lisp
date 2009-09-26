(in-package :thune)

(defparameter *emote-prefix* (format nil "~CACTION" (code-char 1)))

(defhandler revenge (socket message)
  (let ((string (car (last (parameters message)))))
    (when (and string
               (> (length string) (length *emote-prefix*))
               (string= (subseq string 0 (length *emote-prefix*))
                        *emote-prefix*)
               (search (conf-value "nick" *conf*) string))
      (send socket (reply-to message (substitute-string string
                                                        (conf-value "nick" *conf*) (nick (prefix message))))))))