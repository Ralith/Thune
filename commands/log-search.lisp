(in-package :thune)

(defcommand "slog" (socket message)
  (let ((log)
        (index (channel-index (first (parameters message)))))
    (montezuma:search-each index
                           (format nil "parameter-2:\"~a\""
                                   (substitute-string (command-args message)
                                                      "\""
                                                      "\\\""))
                           (lambda (doc-id rank)
                             (when (or (null log)
                                       (> rank (cdr log)))
                               (setf log (cons doc-id rank)))))
    (if log
        (let ((doc (montezuma:get-document index (car log))))
          (send socket (reply-to message
                                 ;; TODO: Abstracted message formatting, time
                                 (format nil "<~a> ~a"
                                         (montezuma:document-value doc "nick")
                                         (montezuma:document-value doc "parameter-2")))))
        (send socket (reply-to message "No matches found.")))))