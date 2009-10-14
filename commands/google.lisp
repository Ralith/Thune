(in-package :thune)

(defun scroogle-search (query)
  (multiple-value-bind (content code headers uri)
      (drakma:http-request "https://ssl.scroogle.org/cgi-bin/nbbw.cgi"
                           :method :post
                           :parameters
                           (list (cons "Gw" query)
                                 (cons "n" "2")))
    (declare (ignore code)
             (ignore headers)
             (ignore uri))
    content))

(defun find-lhtml (lhtml &rest tags)
  (if tags
      (apply #'find-lhtml
             (loop for element in lhtml
                when (and (listp element)
                          (eq (first element) (first tags)))
                return element)
             (rest tags))
      lhtml))

(defcommand "google" (channel message)
  "Replies with the first google result for a given search query."
  (let* ((page (chtml:parse (scroogle-search (command-args message))
                            (chtml:make-lhtml-builder)))
         (result (find-lhtml page :body :blockquote :a))
         (url (second (first (second result))))
         (title (third result)))
    (when (listp title)
      (setf title) (third title))
    (send channel (reply-to message (format nil "~a - ~a"
                                            url title)))))