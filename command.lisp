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
        (if (null first-space)
            (values nil
                    (subseq string 1))
            (values (subseq string (1+ first-space))
                    (subseq string 1 first-space))))
       ((string= nick (subseq string 0 (length nick)))
        (let ((second-space (position #\Space string :start (1+ first-space))))
          (when first-space
            (if (null second-space)
                (values nil
                        (subseq string (1+ first-space)))
                (values (subseq string (1+ second-space))
                        (subseq string (1+ first-space) second-space))))))))))

(defun add-command (function)
  (pushnew function *commands*))

(defmacro defcommand (name args &body body)
  `(progn
     (defun ,name ,args ,@body)
     (add-command ,name)))

(defhandler command-launcher (socket message)
  (multiple-value-bind (args command) (command-args message)
    (loop for command-func in *commands* do
         (when (string= (string-upcase command)
                        (symbol-name command-func))
           (funcall command-func socket args)))))