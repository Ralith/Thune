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
        (input (make-instance 'channel))
        (output (make-instance 'unbounded-channel))
        (reconnect t)
        (ignore (conf-list (conf-value "ignore"))))
    (loop while reconnect do
         (setf socket (connect (conf-value "server")))
         (format t "Connected.~%")
         (register output)
         (pexec ()
          (handler-bind ((disable-reconnect
                          (lambda (c)
                            (declare (ignore c))
                            (setf reconnect nil)))
                         (error
                          (lambda (e)
                            (send output (make-message "QUIT" (format nil "Error: ~a" e))))))
            (handler-case
                (let ((message))
                  (loop
                     (setf message (get-message socket))
                     (unless (and (typep (prefix message) 'user)
                                  (some (lambda (x)
                                          (string-equal x (nick (prefix message))))
                                        ignore))
                       (send input message))))
              (end-of-file ()
                (disconnect socket)
                (send input nil)
                (format t "Disconnected.~%")
                (when reconnect
                  (format t "Reconnecting...~%"))))))
         (pexec ()
           (loop
              (let ((message (recv input)))
                (format t "-> ~a~%" (message->string message))
                (call-handlers output message))))
         (loop
            (let ((message (recv output)))
              (format t "<- ~a~%" (message->string message))
              (send-message socket message))))))

(defun start-background ()
  (pcall #'start))