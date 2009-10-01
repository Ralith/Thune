(in-package :thune)

(defun conf-value (key conf)
  "Finds the value of case-insensitive KEY from CONF, returning nil if no such key exists."
  (cdr (assoc key conf :test #'string-equal)))

(defun (setf conf-value) (value key conf)
  (setf (cdr (assoc key conf :test #'string-equal)) value))

(defun load-conf (path)
  "Parses an INI-style file into an alist."
  (with-open-file (stream path)
    (read-ini stream)))

(defun trim (c str)
  "Trims all instances of C from both ends of STR.  Returns a subsequence of STR."
  (let* ((len (length str))
	 (start 0) (end len))
    (do ((i 0 (1+ i)))
	((char/= c (char str i)))
      (setf start (1+ i)))
    (do ((i  (1- len) (1- i)))
	((char/= c (char str i)))
      (setf end i))
    (subseq str start end)))

(defun read-ini (stream)
  "Parses INI-style data from stream into an alist."
  (let ((res))
    (dolist (line (read-lines stream) res)
      (let ((p (position #\= line)))
	(when p (push
		 (cons (trim #\space (subseq line 0 p))
		       (trim #\space (subseq line (1+ p))))
		 res))))))

(defun read-lines (stream)
  "Reads stream into a list of lines."
  (loop for line = (read-line stream nil)
     until (null line)
     collecting line))

(defun conf-list (string)
  "Returns a list of values derived from comma-seperated conf value STRING."
  (mapcar (lambda (x) (string-trim " " x))
          (split-sequence #\, string)))