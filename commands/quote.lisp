(in-package :thune)

(defvar *quote-db*(list
		   (cons "#gender" (list
				    (cons "coyo"
					  (list "<Zelse> Make me forget. :( * coyo undresses"
						"* coyo feels his stock rising"
						"* E does SCIENCE to Skellie * coyo noms E's SCIENCE"))
				    (cons "winterwyn"
					  (list "* coyo noms Zelse's wangst <winterwyn> suddenly, i'm hungry for something."
						"<Keiya> Hey Mia! TAKE OFF EVERY ZIG. RIGHT NOW. <winterwyn> Isn't she practically busting out of her zig as it is?"))))
		   (cons "#coyo" (list
				  (cons "Ralith"
					(list "<Ralith> Responsibility is hard. * Ralith speaks from experience"))))))

(defcommand "quote" (socket message)
  (send socket (reply-to message (reply-target message) (first (quotes-for (command-args message) *quote-db*)))))

(defcommand "addquote" (socket message)
  (send socket (reply-to message "Command received."))
  (quote-db-check (reply-target message)
		  (first (split-sequence #\$ (command-args message)))
		  *quote-db*)
  (send socket (reply-to message "Channel and nick exist."))
  (if (string= (first (split-sequence #\$ (command-args message))) (nick (prefix message)))
      (send socket (reply-to message "SELF-QUOTER!"))
      (progn (add-quote (reply-target message)
			(first (split-sequence #\$ (command-args message)))
			*quote-db*
			(second (split-sequence #\$ (command-args message))))
	     (send socket (reply-to message "Command comfirmed.")))))

(defun quotes-for (channel nick quote-db)
  (cdr (assoc nick
	      (cdr (assoc channel quote-db :test #'string-equal)) :test #'string-equal)))

(defun quote-db-check (channel nick quote-db)
  (if (not (channel-for channel quote-db)) (push (cons channel (list)) quote-db))
  (if (not (quotes-for channel nick quote-db)) (push (cons nick (list)) (channel-for channel quote-db))))

(defun channel-for (channel quote-db)
  (cdr (assoc channel quote-db :test #'string-equal)))

(defun (setf channel-for) (channel quote-db)
  (setf (cdr (assoc channel quote-db :test #'string-equal)) quote-db))

(defun (setf quotes-for) (quotes channel nick quote-db)
   (setf (cdr (assoc nick
		     (cdr (assoc channel quote-db :test #'string-equal)) :test #'string-equal)) quotes ))

(defun add-quote (channel nick quote-db quote)
  (push quote (quotes-for channel nick quote-db)))

