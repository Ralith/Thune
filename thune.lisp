(in-package :thune)

(defvar *conf* nil
  "The current Thune configuration")

(defun register (socket)
  (send socket (make-message "NICK" (conf-value "nick" *conf*)))
  (send socket (make-message "USER"
                             (conf-value "user" *conf*)
                             "." "."
                             (conf-value "realname" *conf*))))

(defhandler pong (socket message)
  (when (string= (command message) "PING")
    (setf (command message) "PONG")
    (send socket message)))

(define-condition disable-reconnect () ())

(defun start ()
  "Launches the bot."
  (sanify-output)
  (setf *conf* (load-conf "thune.conf"))
  (format t "Connecting...~%")
  (let ((socket)
        (reconnect t)
        (ignore (conf-list (conf-value "ignore" *conf*))))
    (loop while reconnect do
         (setf socket (connect (conf-value "server" *conf*)))
         (format t "Connected.~%")
         (register socket)
         (handler-bind ((disable-reconnect
                         (lambda (c)
                           (declare (ignore c))
                           (setf reconnect nil)))
                        (error
                         (lambda (e)
                           (send socket (make-message "QUIT" (format nil "Error: ~a" e))))))
           (handler-case
               (let ((message))
                (loop
                   (setf message (get-message socket))
                   (format t "-> ~a~%" (message->string message))
                   (unless (and (typep (prefix message) 'user)
                                (some (lambda (x)
                                        (string-equal x (nick (prefix message))))
                                      ignore))
                       (call-handlers socket message))))
             (end-of-file ()
               (disconnect socket)
               (format t "Disconnected.~%")
               (when reconnect
                 (format t "Reconnecting...~%"))))))))
