(in-package :thune)

(defun send-raw (socket string)
  "Sends a raw message over SOCKET, logging to *STANDARD-OUTPUT*."
  (ircl:send-raw socket string)
  (format t "<- ~a~%" string))

(defun reply-target (message)
  "Returns the most appropriate channel or nick to receive a reply to MESSAGE."
  (let ((target (first (parameters message))))
    (if (string= target (conf-value 'nick))
	(nick (prefix message))
	target)))

(defun reply-to (message reply)
  "Generates a message that will send REPLY in a reply to MESSAGE."
  (make-message (command message) (reply-target message) reply))

(defun adminp (user)
  "Returns T if the given user has administrator privledges, or NIL otherwise."
  (some #'identity
        (mapcar (lambda (admin)
                  (string= admin
                           (prefix->string user)))
                (conf-value 'admins))))

(defmacro when-from-admin (message &body body)
  "Executes BODY only when MESSAGE originates from a user with administrator privledges."
  `(when (and (typep (prefix ,message) 'user)
              (adminp (prefix ,message)))
       ,@body))

(defun sanify-output ()
  ;; If we're in SBCL but not swank, force unicode output.
  #+(and sbcl #.(cl:if (cl:find-package "SWANK") '(or) '(and)))
  (progn (setf sb-impl::*default-external-format* :UTF-8)
	 (setf sb-alien::*default-c-string-external-format* :UTF-8)
	 (sb-kernel:stream-cold-init-or-reset)))

(defun substitute-string (sequence old-pattern new-pattern)
  "Return SEQUENCE with all instances of OLD-PATTERN replaced with NEW-PATTERN."
  (let ((position (search old-pattern sequence))
        (result (copy-seq sequence)))
    (loop while position do
         (setf result
               (concatenate 'string
                            (subseq result 0 position)
                            new-pattern
                            (subseq result (+ position (length old-pattern)))))
         (setf position (search old-pattern result)))
    result))

(defun emotep (message)
  "Determines if MESSAGE is an IRC emote."
  (let ((string (car (last (parameters message))))
        (end (1+ (length "ACTION"))))
    (and (ctcpp message)
         string
         (> (length string) end)
         (string= (subseq string 1 end)
                  "ACTION"))))

(defun ctcpp (message)
  "Determines if MESSAGE is an IRC CTCP."
  (let* ((string (second (parameters message)))
         (length (length string)))
    (when (> length 0)
      (char= (code-char 1)
             (aref string 0) (aref string (1- length))))))

(defun ctcp-command (message)
  "Returns the CTCP command contained within MESSAGE, with the arguments, if any, in a second return value, or NIL if MESSAGE is not a CTCP."
  (when (ctcpp message)
    (destructuring-bind (command &optional arguments)
        (split-sequence #\Space (second (parameters message)))
      (values (subseq command 1)
              (when arguments
                (subseq arguments 0 (1- (length arguments))))))))

;;; TODO: Take a list of var-factor pairs
(defmacro %format-interval-distribute (vars factors)
  "Distributes (FIRST VARS) amongst (REST VARS) such that the value of each VAR is less than its corresponding FACTOR.  The factor corresponding to the last element of VARS, if any, is ignored to ensure support for large values."
  (let ((stack (gensym))
        (result (gensym))
        (remainder (gensym)))
   `(let ((,stack (quote ,factors)))
      ,@(mapcar (lambda (lower higher)
                  `(multiple-value-bind (,result ,remainder)
                       (floor ,lower (pop ,stack))
                     (setf ,higher ,result)
                     (setf ,lower ,remainder)))
                vars (rest vars)))))

(defmacro %format-interval-string (vars names)
  "Returns a human-readable string of the values of VARS referred to with their respective NAMES."
  (let ((in-string (gensym))
        (string (gensym)))
    `(let ((,in-string nil)
           (,string))
       ,@(mapcar (lambda (var name)
                  (let ((control-string (format nil "~~a ~a~~:p" name)))
                    `(when (> ,var 0)
                       (setf ,string
                             (concatenate 'string
                                          ,string
                                          (when ,in-string ", ")
                                          (format nil ,control-string ,var)))
                       (setf ,in-string t))))
                 vars names)
       ,string)))

(defun format-interval (seconds)
  "Returns a human-readable string representing the duration SECONDS in years, months, weeks, days, hours, minutes, and seconds, omitting zero values."
  (if (< seconds 1)
      "no time"
      (let ((years) (months) (weeks) (days) (hours) (minutes))
        (%format-interval-distribute (seconds minutes hours days weeks months years)
                                     (60 60 24 7 4 12))
        (%format-interval-string (years months weeks days hours minutes seconds)
                                 ("year" "month" "week" "day" "hour" "minute" "second")))))

(defun binary-search (value array &key
                      (test #'=)
                      (order #'<)
                      (lower-bound 0)
                      (upper-bound (length array)))
  "Performs a binary search to locate value (as identified by TEST) in the segment of ARRAY between LOWER-BOUND and UPPER-BOUND, which must be sorted such that ORDER returns non-NIL when comparing any element to any element following it, and NIL otherwise.  The first return value is the element of ARRAY found, or NIL if none, and the second return value is T if the element was found and NIL otherwise."
  (let* ((midpoint (+ lower-bound
                      (floor (- upper-bound lower-bound) 2)))
         (midpoint-value (aref array midpoint)))
    (cond
      ((funcall test value midpoint-value)
       (values midpoint-value t))
      ((< (- upper-bound lower-bound) 2)
       (values nil nil))
      ((funcall order value midpoint-value)
       (binary-search value array
                      :test test :order order
                      :lower-bound lower-bound :upper-bound midpoint))
      (t
       (binary-search value array
                      :test test :order order
                      :lower-bound midpoint :upper-bound upper-bound)))))

(defun find-nested-tag (document &rest tags)
  "Returns the block arrived at by descending into each of TAGS sequentially in the xmls-style tree DOCUMENT."
  (if tags
      (apply #'find-nested-tag
             (loop for element in document
                when (and (listp element)
                          (equal (first element) (first tags)))
                return element)
             (rest tags))
      document))
