(in-package :thune)

(defvar *commands* ())

(defun command-args (message)
  (when (or (string= "PRIVMSG" (command message))
            (string= "NOTICE" (command message)))
    (let ((string (car (last (parameters message))))
          (nick (conf-value "nick" *conf*)))
     (cond
       ((char= (aref (conf-value "cmdchar" *conf*) 0)
               (aref string 0))
        (subseq string 1))
       ((string= nick (subseq string 0 (length nick)))
        (subseq string (1+ (position #\Space string))))))))

(defun command-name (command-args)
  (let ((delim (position #\Space command-args)))
    (if delim
      (subseq command-args delim)
      command-args)))

(defun add-command (function)
  (pushnew function *commands*))

(defmacro defcommand (name args &body body)
  `(progn
     (defun ,name ,args ,@body)
     (add-command ,name)))

(defhandler command-launcher (socket message)
  (let* ((args (get-command message))
         (command (command-name args)))
    (loop for command-func in *commands* do
         (when (string= (string-upcase command)
                        (symbol-name command-func))
           (funcall command-func socket args)))))