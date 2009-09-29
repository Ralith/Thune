(in-package :thune)

(defcommand "seen" (socket message)
  (let* ((nick (command-args message))
         (last (cdr (assoc nick *seen* :test #'string-equal)))
         (reply))
    (setf reply
          (if last
              (format nil "Last saw ~a ~a, ~a"
                      nick
                      (multiple-value-bind (seconds minutes hours date month year)
                          (decode-universal-time (received message) 0)
                        (format nil "at ~a:~a:~a GMT on the ~a of ~a, ~a"
                                hours minutes seconds date month year))
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
                                                   (when (> (length string) text-start) (subseq string (1- (length string))))))
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
                        (t "doing something strange.")))
              (format nil "I've never seen anyone going by \"~a\"." nick)))
    (send socket (reply-to message reply))))