(in-package :thune)

(defcommand "zup" (socket message)
  (send socket (reply-to message "zup")))

(defcommand "nom" (socket message)
  (send socket (reply-to message (format nil "~CACTION noms ~a eagerly~~~C"
    (code-char 1)
    (if (string= (command-args message) "")
      "everyone"
      (command-args message))
    (code-char 1)))))

(defcommand "xkcd" (socket message)
  (let* ((age-1 (read-from-string (first (split-sequence #\Space (command-args message)))))
	(age-2 (read-from-string (second (split-sequence #\Space (command-args message)))))
	(age-elder (max age-1 age-2))
	(age-younger (min age-1 age-2))
	(age-checker (+ 7 (/ age-elder 2)))
	(age-result (if (<= age-checker age-younger)
			(format nil "This bond is licensed: ~a / 2 + 7 = ~a, which is <= ~a."
				age-elder (float age-checker) age-younger)
			(format nil "This bond is forbidden: ~a / 2 + 7 = ~a, which is > ~a"
				age-elder (float age-checker) age-younger))))
    (send socket (reply-to message age-result))))