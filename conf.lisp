(in-package :thune)

(defvar *conf* nil
  "The current Thune configuration")

(defun conf-value (key)
  "Finds the value associated in the configuration with symbol KEY, returning nil if no such key exists."
  (cdr (assoc key *conf*)))

(defun (setf conf-value) (value key)
  (setf (cdr (assoc key *conf*)) value))

(defun load-conf (path)
  "Loads a Thune config file."
  (setf *conf*
        (with-open-file (stream path)
          (let ((*package* (find-package :thune)))
            (loop
               for entry = (read stream nil nil)
               while entry
               collect entry)))))