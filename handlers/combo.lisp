(in-package :thune)

(defvar *last-message* ())
(defvar *repetition-count* ())

(defhandler combo (socket message)
  (when (string= "PRIVMSG" (command message))
    (let ((string (car (last (parameters message)))))
      (let* ((channel (first (parameters message)))
             (current (assoc channel *last-message*
                             :test #'string-equal)))
        (if current
            (let ((current-count (assoc channel *repetition-count*
                                        :test #'string-equal)))
              (if (string= string (cdr current))
                  (if current-count
                      (incf (cdr current-count))
                      (push (cons channel 1) *repetition-count*))
                  (progn
                    (setf (cdr current) string)
                    (when current-count
                      (setf (cdr current-count) 1))))
              (when (and current-count
                         (>= (cdr current-count) 3))
                (send socket (reply-to message string))
                (setf (cdr current-count) 0)))
            (push (cons channel string)
                  *last-message*))))))