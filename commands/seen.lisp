(in-package :thune)

(defcommand "seen" (socket message)
  "Replies with the time since provided nick has been seen, and what s/he was doing at the time."
  (let* ((nick (command-args message))
         (last (cdr (assoc nick *seen* :test #'string-equal)))
         (reply))
    (setf reply
          (if (string= nick (conf-value "nick"))
              "sup"
              (if last
                  (format nil "Last saw ~a ~a ago, ~a"
                          nick
                          (format-interval (- (get-universal-time) (received last)))
                          (cond
                            ((or (string-equal (command last) "PRIVMSG")
                                 (string-equal (command last) "NOTICE"))
                             (format nil "speaking to ~a, ~a."
                                     (first (parameters last))
                                     (if (ctcpp last)
                                         (if (emotep last)
                                             (format nil "emoting \"* ~a ~a\""
                                                     nick
                                                     (let* ((string (second (parameters last)))
                                                            (text-start (1+ (position #\Space string))))
                                                       (when (> (length string) text-start) (subseq string text-start (1- (length string))))))
                                             (format nil "sending a CTCP \"~a\"" (let ((string (second (parameters last))))
                                                                                   (subseq string 1 (1- (length string))))))
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
                                         "nothing.")))
                            ((string-equal (command last) "NICK")
                             (format nil "changing nick to \"~a\"."
                                     (first (parameters last))))
                            (t "doing something strange.")))
                  (format nil "I've never seen anyone going by \"~a\"." nick))))
    (send socket (reply-to message reply))))