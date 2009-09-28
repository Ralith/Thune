(in-package :thune)

(defcommand "seen" (socket message)
  (let* ((nick (nick (prefix message)))
         (last (cdr (assoc nick *seen* :test #'string-equal))))
    (send
     socket
     (reply-to
      message
      (if last
          (format nil "Last saw ~a ~a"
                  nick
                  (cond
                    ((or (string-equal (command last) "PRIVMSG")
                         (string-equal (command last) "NOTICE"))
                     (format nil "speaking in ~a, saying \"~a\"."
                             (first (parameters last))
                             (second (parameters last))))
                    ((string-equal (command last) "PART")
                     (format nil "leaving ~a, saying ~a."
                             (first (parameters last))
                             (if (second (parameters list))
                                 (format nil "\"~a\"" (second (parameters list)))
                                 "nothing.")))
                    ((string-equal (command last) "JOIN")
                     (format nil "joining ~a." (first (parameters last))))
                    ((string-equal (command last) "QUIT")
                     "quitting.")))
          (format nil "I've never seen ~a." nick))))))