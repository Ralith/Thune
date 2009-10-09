(in-package :thune)

(defhandler autojoin (channel message)
  (when (string= "001" (command message)) ;RPL_WELCOME; see RFC2812 section 5.1
    (send channel
          (make-message "JOIN" (conf-value "channels")))))