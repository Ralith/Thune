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

(defhandler log-input (socket message)
  (declare (ignore socket))
  (format t "-> ~a~%" (message->string message)))

(define-condition disable-reconnect () ())

(defun start ()
  "Launches the bot."
  (sanify-output)
  (setf *conf* (load-conf "thune.conf"))
  (format t "Connecting...~%")
  (let ((socket)
        (reconnect t))
    (loop while reconnect do
         (setf socket (connect (conf-value "server" *conf*)))
         (format t "Connected.~%")
         (register socket)
         (handler-case
             (handler-bind ((disable-reconnect
                             (lambda (c)
                               (declare (ignore c))
                               (setf reconnect nil)
                               (continue))))
               (handler-case
                   (loop (call-handlers socket (get-message socket)))
                 (end-of-file ()
                   (disconnect socket)
                   (format t "Disconnected.~%")
                   (when reconnect
                     (format t "Reconnecting...~%")))
                 (error (e)
                   (signal 'disable-reconnect)
                   (send socket (make-message "QUIT" (format nil "Error: ~a" e)))
                   (error e))))))))
