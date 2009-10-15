(in-package :thune)

;;; Ensures that (conf-value 'nick) remains up to date
(defhandler nick-track (channel message)
  (declare (ignore channel))
  (when (and (string-equal "NICK" (command message))
             (string-equal (conf-value 'nick)
                           (nick (prefix message))))
    (setf (conf-value 'nick) (first (parameters message)))))