(in-package :thune)

(defun google-weather (location)
  (multiple-value-bind (content code headers uri)
      (drakma:http-request
       "http://www.google.com/ig/api"
       :parameters (list (cons "weather" location)))
    (declare (ignore code)
             (ignore headers)
             (ignore uri))
    (let ((weather (find-nested-tag (xmls:parse content) "weather" "current_conditions")))
      (when weather
        (flet ((get-value (x) (second (first (second x)))))
          (list
           (cons :condition (get-value (find-nested-tag weather "condition")))
           (cons :temperature (get-value (find-nested-tag weather "temp_c")))
           (cons :humidity (get-value (find-nested-tag weather "humidity")))
           (cons :wind (get-value (find-nested-tag weather "wind_condition")))))))))

(defcommand "weather" (channel message)
  (let* ((location (command-args message))
         (weather (google-weather location)))
    (if weather
        (let ((condition (cdr (assoc :condition weather)))
              (temperature (cdr (assoc :temperature weather)))
              (humidity (cdr (assoc :humidity weather)))
              (wind (cdr (assoc :wind weather))))
          (send channel (reply-to message (format nil "~a is ~a. Temperature: ~aC; ~a; ~a."
                                                  location condition temperature humidity wind))))
        (send channel (reply-to message (format nil "Unable to find weather for location \"~a\"" location))))))
