(in-package :thune)

(defvar *conf* nil
  "The current Thune configuration")

(defun register (socket)
  (send socket (make-message "NICK" (list (conf-value "nick" *conf*))))
  (send socket (make-message "USER" (list (conf-value "user" *conf*)
                                          "." "."
                                          (conf-value "realname" *conf*)))))

(defhandler pong (socket message)
  (when (string= (command message) "PING")
    (setf (command message) "PONG")
    (send socket message)))

(defhandler log-input (socket message)
  (declare (ignore socket))
  (format t "-> ~a~%" (message->string message)))

(defun start ()
  "Launches the bot."
  (sanify-output)
  (setf *conf* (load-conf "thune.conf"))
  (let ((socket (connect (conf-value "server" *conf*))))
    (register socket)
    (loop (call-handlers socket (get-message socket)))))