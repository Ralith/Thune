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

(defun add-command (function)
  (pushnew function *commands*))

(defmacro defcommand (name args &body body)
  `(progn
     (defun ,name ,args ,@body)
     (add-command (quote ,name))))

(defhandler command-launcher (socket message)
  (multiple-value-bind (args command) (command-args message)
    (declare (ignore args))
    (when (and command (< 0 (length command)))
      (loop for command-func in *commands* do
           (when (string= (string-upcase command)
                          (symbol-name command-func))
             (funcall command-func socket message))))))