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
                             (when (or (null log)
                                       (> rank (cdr log)))
                               (setf log (cons doc-id rank)))))
    (if log
        (let ((doc (montezuma:get-document *montezuma-logs* (car log))))
          (send socket (reply-to message
                                 ;; TODO: Abstracted message formatting
                                 (format nil "<~s> ~s"
                                         (montezuma:document-field doc "nick")
                                         (montezuma:document-field doc "parameter-2")))))
        (send socket (reply-to message "No matches found.")))))