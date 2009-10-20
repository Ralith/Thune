(in-package :thune)

(defvar *commands* ()
  "An alist of command names associated with function specifiers to be called for the associated command.")

(defun command-args (message)
  "In the first value, returns the portion of MESSAGE's text that is not a command or prompt (e.g. \"!foo bar\" => \"bar\", \"MyBot: foo bar baz\" => \"bar baz\", \"!foo\" => \"\".  In the second value, returns the command name.  Returns NIL if MESSAGE is not formatted as a command."
  (when (or (string= "PRIVMSG" (command message))
            (string= "NOTICE" (command message)))
    (let* ((string (car (last (parameters message))))
           (first-space (position #\Space string))
           (nick (conf-value 'nick)))
      (cond
        ((char= (aref (conf-value 'cmdchar) 0)
                (aref string 0))
         (if first-space
             (values (string-trim " " (subseq string (1+ first-space)))
                     (subseq string 1 first-space))
             (values ""
                     (subseq string 1))))
        ((and (> (length string) (length nick))
          (string= nick (subseq string 0 (length nick))))
         (when first-space
           (let ((second-space (position #\Space string
                                         :start (1+ first-space))))
             (if second-space
                 (values (string-trim " " (subseq string (1+ second-space)))
                         (subseq string (1+ first-space) second-space))
                 (values ""
                         (subseq string (1+ first-space)))))))))))

(defun add-command (name function)
  "Configures a command for use, overriding the previous use of the given command name, if any."
  (let ((current (assoc name *commands*
                        :test #'string-equal)))
    (if current
        (setf (cdr current) function)
        (push (cons name function) *commands*)))
  *commands*)

(defun find-command (name)
  "Returns the function identifier associated with NAME, or NIL if none is found."
  (cdr (assoc name *commands* :test #'string-equal)))

(defmacro defcommand (name args &body body)
  "Defines and configures for use a new command.  Note that NAME must be a SEQUENCE (usually a string)."
  (let ((func-name (intern (concatenate 'string
                                        "COMMAND-"
                                        (string-upcase name)))))
    `(progn
       (defun ,func-name ,args ,@body)
       (add-command ,name (quote ,func-name)))))

(defun spawn-command (channel message command-name)
  "Spawns the named command, if it exists."
  (let ((command (find-command command-name)))
    (when command
      (pexec (:name (format nil "Transient Command: ~a" command-name))
        (handler-case
            (funcall command channel message)
          (error (e)
            (send channel (reply-to message (substitute #\\ #\Linefeed (format nil "Error executing command ~a: ~a" command-name e))))))))))

(defhandler command-launcher (channel message)
  "Determines if MESSAGE contains a command, and, if so, spawns it."
  (multiple-value-bind (args command-name) (command-args message)
    (declare (ignore args))
    (spawn-command channel message command-name)))