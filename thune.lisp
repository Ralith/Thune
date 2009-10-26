(in-package :thune)

(defun register (channel)
  (send channel (make-message "NICK" (conf-value 'nick)))
  (send channel (make-message "USER"
                              (conf-value 'user)
                              "." "."
                              (conf-value 'realname))))

(defhandler pong (socket message)
  (when (string= (command message) "PING")
    (setf (command message) "PONG")
    (send socket message)))

(defvar *reconnect*)
(defvar *socket* nil)
(defvar *start-time* nil)

(defun start ()
  "Launches the bot."
  (sanify-output)
  (setf drakma:*drakma-default-external-format* :utf-8)
  (setf %thread-pool-soft-limit 64)
  (setf *reconnect* t)
  (setf *start-time* (get-universal-time))
  (load-conf "thune.conf")
  (let ((input (make-instance 'channel))
        (output (make-instance 'unbounded-channel)))
    (format t "Connecting...~%")
    (pexec (:name "Connection Manager")
      (loop
         (setf *socket* (connect (conf-value 'server)))
         (format t "Connected.~%")
         (register output)
         (handler-case
             (loop
                (let ((message))
                  (setf message (get-message *socket*))
                  (unless (and (typep (prefix message) 'user)
                               (some (lambda (x)
                                       (string-equal x (nick (prefix message))))
                                     (conf-value 'ignore)))
                    (send input message))))
           (end-of-file ()
             (format t "Disconnected.~%")
             (if *reconnect*
                 (format t "Reconnecting...~%")
                 (progn
                   (send input nil)
                   (send output nil)
                   (return))))))
      (format t "Connection manager terminating.~%"))
    (pexec (:name "Handler Dispatch")
      
      (format t "Handler dispatch terminating.~%"))
    (let ((running t))
     (loop while running do
          (select
            ((recv input message)
             (if message
                 (progn
                   (format t "-> ~a~%" (message->string message))
                   (handler-bind
                       ((error (lambda (e)
                                 (send output (make-message "QUIT" (format nil "Error: ~a" e))))))
                     (call-handlers output message)))
                 (setf running nil)))
            ((recv output message)
             (if message
                 (progn
                   (send-message *socket* message)
                   (format t "<- ~a~%" (message->string message)))
                 (setf running nil))))))
    (format t "Main thread terminating.~%")))

(defun start-background ()
  (pcall #'start :name "Main (Message Transmission)"))