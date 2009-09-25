(in-package :thune)

(defhandler autojoin (socket message)
  (when (string= "001" (command message)) ;RPL_WELCOME; see RFC2812 section 5.1
    (send socket
          (make-message "JOIN" (conf-value "channels" *conf*)))))