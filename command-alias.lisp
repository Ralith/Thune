(in-package :thune)

(defvar *aliases* ()
  "alist mapping aliases to commands.")

(defun alias-target (name)
  (cdr (assoc name *aliases* :test #'string-equal)))

(defun (setf alias-target) (command-name alias-name)
  (let ((old (assoc alias-name *aliases* :test #'string-equal)))
    (if old
        (setf (cdr old) command-name)
        (push (cons alias-name command-name) *aliases*))))

(defhandler alias-launcher (channel message)
  "Determines if MESSAGE contains a command alias, and, if so, spawns the associated command."
  (multiple-value-bind (args command-name) (command-args message)
    (declare (ignore args))
    (let ((alias-command (alias-target command-name)))
      (when alias-command
       (spawn-command channel message alias-command)))))

(defmacro defaliases (command-name &rest alias-names)
  (let ((name (gensym)))
    `(mapc (lambda (,name) (setf (alias-target ,name) ,command-name))
           (quote ,alias-names))))