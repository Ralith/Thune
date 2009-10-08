(in-package :thune)

(defcommand "slog" (socket message)
  (let ((log))
    (montezuma:search-each *montezuma-logs*
                           ;; TODO: Limit to channel
                           (format nil "parameter-2:\"~s\""
                                   (substitute-string (command-args message)
                                                      "\""
                                                      "\\\""))
                           (lambda (doc-id rank)
                             (if (or (null log)
                                     (> rank (cdr log)))
                                 (setf log (cons doc-id rank)))))
    (let ((doc (montezuma:get-document *montezuma-logs* (car log))))
     (send socket (reply-to message
                            (format nil "<~s> ~s"
                                    (montezuma:document-field doc "nick")
                                    (montezuma:document-field doc "parameter-2")))))))