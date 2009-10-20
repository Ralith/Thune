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
           (cons :fahrenheit (get-value (find-nested-tag weather "temp_f")))
           (cons :celsius (get-value (find-nested-tag weather "temp_c")))
           (cons :humidity (get-value (find-nested-tag weather "humidity")))
           (cons :wind (get-value (find-nested-tag weather "wind_condition")))))))))

(defun google-forecast (location)
  (multiple-value-bind (content code headers uri)
      (drakma:http-request
       "http://www.google.com/ig/api"
       :parameters (list (cons "weather" location)))
    (declare (ignore code)
             (ignore headers)
             (ignore uri))
    (let ((data (find-nested-tag (xmls:parse content) "weather")))
      (when data
        (remove nil (mapcar
                     (lambda (forecast)
                       (when (and (listp forecast)
                                  (string= (first forecast) "forecast_conditions"))

                         (flet ((get-value (x) (second (first (second x)))))
                           (list
                            (cons :day (get-value (find-nested-tag forecast "day_of_week")))
                            (cons :low (get-value (find-nested-tag forecast "low")))
                            (cons :high (get-value (find-nested-tag forecast "high")))
                            (cons :condition (get-value (find-nested-tag forecast "condition")))))))
                     (cddr data)))))))

(defaliases "weather" "w")
(defcommand "weather" (channel message)
  "Replies with current weather conditions for the supplied location."
  (let ((location (maybe-cache "weather"
                                (nick (prefix message))
                                (command-args message))))
    (when location
      (let ((weather (google-weather location)))
        (if weather
            (let ((condition (cdr (assoc :condition weather)))
                  (celsius (cdr (assoc :celsius weather)))
                  (fahrenheit (cdr (assoc :fahrenheit weather)))
                  (humidity (cdr (assoc :humidity weather)))
                  (wind (cdr (assoc :wind weather))))
              (send channel (reply-to message (format nil "~a is ~a. Temperature: ~aC/~aF; ~a; ~a."
                                                      location condition celsius fahrenheit humidity wind))))
            (send channel (reply-to message (format nil "Unable to find weather for location \"~a\"" location))))))))

(defaliases "forecast" "f")
(defcommand "forecast" (channel message)
  "Replies with forecasts for the near future at location."
  (let ((location (maybe-cache "forecast"
                               (nick (prefix message))
                               (command-args message))))
    (when location
      (let ((forecast (google-forecast location)))
       (if forecast
           (send channel
                 (reply-to message
                           (reduce (lambda (accum value)
                                     (concatenate 'string accum "; " value))
                                   (mapcar (lambda (day)
                                             (format nil "~a~a~a: ~a with temperatures from ~aC/~aF to ~aC/~aF"
                                                     (code-char 2)
                                                     (cdr (assoc :day day))
                                                     (code-char 2)
                                                     (cdr (assoc :condition day))
                                                     (round (/ (* (- (read-from-string (cdr (assoc :low day)))
                                                                     32)
                                                                  5)
                                                               9))
                                                     (cdr (assoc :low day))
                                                     (round (/ (* (- (read-from-string (cdr (assoc :high day)))
                                                                     32)
                                                                  5)
                                                               9))
                                                     (cdr (assoc :high day))))
                                           forecast))))
           (send channel (reply-to message (format nil "Unable to find forecast for location \"~a\"" location))))))))