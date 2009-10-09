(in-package :thune)

(defun register (channel)
  (send channel (make-message "NICK" (conf-value "nick")))
  (send channel (make-message "USER"
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
  (setf drakma:*drakma-default-external-format* :utf-8)
  (load-conf "thune.conf")
  (format t "Connecting...~%")
  (let ((socket)
        (read-channel (make-instance 'channel))
        (write-channel (make-instance 'channel))
        (reconnect t)
        (ignore (conf-list (conf-value "ignore"))))
    (loop while reconnect do
         (setf socket (connect (conf-value "server")))
         (format t "Connected.~%")
         (register write-channel)
         (pexec ()
          (handler-bind ((disable-reconnect
                          (lambda (c)
                            (declare (ignore c))
                            (setf reconnect nil)))
                         (error
                          (lambda (e)
                            (send write-channel (make-message "QUIT" (format nil "Error: ~a" e))))))
            (handler-case
                (let ((message))
                  (loop
                     (setf message (get-message socket))
                     (unless (and (typep (prefix message) 'user)
                                  (some (lambda (x)
                                          (string-equal x (nick (prefix message))))
                                        ignore))
                       (send read-channel message))))
              (end-of-file ()
                (disconnect socket)
                (send read-channel nil)
                (format t "Disconnected.~%")
                (when reconnect
                  (format t "Reconnecting...~%"))))))
         (pexec ()
           (loop
              (let ((message (recv read-channel)))
                (format t "-> ~a~%" (message->string message))
                (call-handlers write-channel message))))
         (loop
            (let ((message (recv write-channel)))
              (format t "<- ~a~%" (message->string message))
              (send-message socket message))))))

(defun start-background ()
  (pcall #'start))