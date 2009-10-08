(in-package :thune)

(defun send (socket message)
  "Sends a message over SOCKET, logging to *STANDARD-OUTPUT*."
  (ircl:send-message socket message)
  (format t "<- ~a~%" (ircl:message->string message)))

(defun send-raw (socket string)
  "Sends a raw message over SOCKET, logging to *STANDARD-OUTPUT*."
  (ircl:send-raw socket string)
  (format t "<- ~a~%" string))

(defun reply-target (message)
  "Returns the most appropriate channel or nick to receive a reply to MESSAGE."
  (let ((target (first (parameters message))))
    (if (string= target (conf-value "nick"))
	(nick (prefix message))
	target)))

(defun reply-to (message reply)
  "Generates a message that will send REPLY in a reply to MESSAGE."
  (make-message (command message) (reply-target message) reply))

(defmacro when-from-admin (message &body body)
  "Executes BODY only when MESSAGE originates from hostmask listed in the admins section of the configuration."
  `(when (some #'identity (mapcar (lambda (admin) (string= admin (prefix->string (prefix ,message))))
                                  (mapcar (lambda (str) (trim #\space str))
                                          (split-sequence:split-sequence #\, (conf-value "admins")))))
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
  (let* ((string (car (last (parameters message))))
         (length (length string)))
    (when (> length 0)
      (char= (code-char 1)
             (aref string 0) (aref string (1- length))))))

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