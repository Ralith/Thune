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
                     (format nil "speaking in ~a, ~a."
                             (first (parameters last))
                             (if (emotep last)
                                 (format nil "emoting \"* ~a ~a\""
                                         nick (second (parameters last)))
                                 (format nil "saying \"~a\"" (second (parameters last))))))
                    ((string-equal (command last) "PART")
                     (format nil "leaving ~a, saying ~a."
                             (first (parameters last))
                             (if (second (parameters last))
                                 (format nil "\"~a\"" (second (parameters last)))
                                 "nothing.")))
                    ((string-equal (command last) "JOIN")
                     (format nil "joining ~a." (first (parameters last))))
                    ((string-equal (command last) "QUIT")
                     (format nil "quitting, saying ~a."
                             (if (first (parameters last))
                                 (format nil "\"~a\"" (first (parameters last)))
                                 "nothing.")))))
          (format nil "I've never seen ~a." nick))))))