(in-package :thune)

(defvar *seen* ())

(defhandler seen (channel message)
  (declare (ignore channel))
  (when (typep (prefix message) 'user)
   (let* ((nick (nick (prefix message)))
          (cons (assoc nick *seen* :test #'string-equal)))
     (if cons
         (setf (cdr cons) message)
         (push (cons nick message) *seen*)))))