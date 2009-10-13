(in-package :thune)

(defcommand "google" (channel message)
  "Replies with the first google result for a given search query."
  (multiple-value-bind (content result headers uri)
      (drakma:http-request "http://www.google.com/search"
                           :parameters
                           (list (cons "q" (command-args message))
                                 (cons "btnI" "I'm Feeling Lucky")))
    (declare (ignore content)
             (ignore result)
             (ignore headers))
    (send channel (reply-to message (let ((string (princ-to-string uri)))
                                     (subseq string 0 (position #\? string :from-end t)))))))