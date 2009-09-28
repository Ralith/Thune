(in-package :thune)

(defcommand "seen" (socket message)
  (let* ((nick (nick (prefix message)))
         (last (assoc nick *seen* :test #'string-equal)))
    (send socket (reply-to message (if last
                                       (format nil "I saw ~a recently." nick)
                                       (format nil "I've never seen ~a." nick))))))