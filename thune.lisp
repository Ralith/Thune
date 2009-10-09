(in-package :thune)

(defun register (socket)
  (send socket (make-message "NICK" (conf-value "nick")))
  (send socket (make-message "USER"
                             (conf-value "user")
                             "." "."
                             (conf-value "realname"))))

(defhandler pong (socket message)
  (when (string= (command message) "PING")
    (setf (command message) "PONG")
    (send socket message)))

(define-condition disable-reconnect () ())

(defun start ()
  "Launches the bot."
  (sanify-output)
  (load-conf "thune.conf")
  (format t "Connecting...~%")
  (let ((socket)
        (reconnect t)
        (ignore (conf-list (conf-value "ignore"))))
    (loop while reconnect do
         (setf socket (connect (conf-value "server")))
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

(defun start-background ()
  #+sbcl (sb-thread:make-thread #'start :name 'thune))