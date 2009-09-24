(in-package :thune)

(defvar *commands* ())

(defun command-args (message)
  (when (or (string= "PRIVMSG" (command message))
            (string= "NOTICE" (command message)))
    (let* ((string (car (last (parameters message))))
           (first-space (position #\Space string))
           (nick (conf-value "nick" *conf*)))
      (cond
        ((char= (aref (conf-value "cmdchar" *conf*) 0)
                (aref string 0))
         (if first-space
             (values (subseq string (1+ first-space))
                     (subseq string 1 first-space))
             (values ""
                     (subseq string 1))))
        ((string= nick (subseq string 0 (length nick)))
         (when first-space
           (let ((second-space (position #\Space string
                                         :start (1+ first-space))))
             (if second-space
                 (values (subseq string (1+ second-space))
                         (subseq string (1+ first-space) second-space))
                 (values ""
                         (subseq string (1+ first-space)))))))))))

(defun add-command (name function)
  (let ((current (assoc name *commands*
                        :test #'string-equal)))
    (if current
        (setf (cdr current) function)
        (push (cons name function) *commands*)))
  *commands*)

(defmacro defcommand (name args &body body)
  (let ((func-name (intern (concatenate 'string
                                        "COMMAND-" name))))
    `(progn
       (defun ,func-name ,args ,@body)
       (add-command ,name (quote ,func-name)))))

;; TODO: Parallelize command execution
(defhandler command-launcher (socket message)
  (multiple-value-bind (args command-name) (command-args message)
    (declare (ignore args))
    (let ((command (assoc command-name *commands*
                          :test #'string-equal)))
      (when command
        (funcall (cdr command) socket message)))))