(in-package :thune)

(defvar *conf* nil
  "The current Thune configuration")

(defun register (socket)
  (send-message socket (make-message "NICK" (list (conf-value "nick" *conf*))))
  (send-message socket (make-message "USER" (list (conf-value "user" *conf*)
                                                  "" ""
                                                  (conf-value "realname" *conf*)))))

(defhandler pong (socket message)
  (when (string= (command message) "PING")
    (setf (command message) "PONG")
    (send-message socket message)))

(defun start ()
  "Launches the bot."
  (sanify-output)
  (setf *conf* (load-conf "./thune.conf"))
  (let ((socket (connect (conf-value "server" *conf*))))
    (register socket)
    (loop (mapcar (lambda (handler)
                    (funcall handler socket (get-message socket)))
                  *handlers*))))