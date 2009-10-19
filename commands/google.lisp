(in-package :thune)

(defun scroogle-search (query)
  "Returns in the first value the first URL search result, and in the second value its title, or NIL if not results found."
  (multiple-value-bind (content code headers uri)
      (drakma:http-request "https://ssl.scroogle.org/cgi-bin/nbbw.cgi"
                           :method :post
                           :parameters
                           (list (cons "Gw" query)
                                 (cons "n" "2")))
    (declare (ignore code)
             (ignore headers)
             (ignore uri))
    (let* ((page (chtml:parse content
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
                             title-markup))))))

(defcommand "google" (channel message)
  "Replies with the first google result for a given search query."
  (multiple-value-bind (url title)
      (scroogle-search (command-args message))
    (send channel (reply-to message
                            (if url (format nil "~a - ~a"
                                            url title)
                                "No results found.")))))
