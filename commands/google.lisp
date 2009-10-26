(in-package :thune)

(defun scroogle-search (query)
  "Returns in the first value the first URL search result, and in the second value its title, or NIL if not results found."
  (let* ((content (drakma:http-request "https://ssl.scroogle.org/cgi-bin/nbbw.cgi"
                                       :method :post
                                       :parameters
                                       (list (cons "Gw" query)
                                             (cons "n" "2"))))
         (page (chtml:parse content
                            (chtml:make-lhtml-builder)))
         (result (find-nested-tag page :body :blockquote :a))
         (url (second (first (second result))))
         (title-markup (cddr result)))
    (values url
            (apply #'concatenate 'string
                   (mapcar (lambda (x)
                             (if (listp x)
                                 (progn (assert (eq :b (first x)))
                                        (third x))
                                 x))
                           title-markup)))))

(defaliases "google" "g")
(defcommand "google" (channel message)
  "Replies with the first google result for a given search query."
  (multiple-value-bind (url title)
      (scroogle-search (command-args message))
    (send channel (reply-to message
                            (if url
                                (format nil "~a - ~a" url title)
                                "No results found.")))))

(defaliases "tvtropes" "trope")
(defcommand "tvtropes" (channel message)
  "Searches for a tvtropes article pertaining to the given query."
  (multiple-value-bind (url title)
      (scroogle-search (format nil "site:tvtropes.org ~a" (command-args message)))
    (send channel (reply-to message
                            (if url (format nil "~a - ~a"
                                            url title)
                                "No results found.")))))

(defaliases "wikipedia" "wp" "wiki")
(defcommand "wikipedia" (channel message)
  "Searches for a wikipedia article pertaining to the given query."
  (multiple-value-bind (url title)
      (scroogle-search (format nil "site:en.wikipedia.org ~a" (command-args message)))
    (send channel (reply-to message
                            (if url (format nil "~a - ~a"
                                            url title)
                                "No results found.")))))
