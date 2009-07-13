(command
 :call-string "reload-plugins"
 :documentation "Recompiles and reloads all plugins."
 :action #.(lambda (message)
	     (when-from-admin message
	       (let ((err) (file))
		 (handler-case
		     (progn
		       (dolist (load-file (list-directory (conf-value "plugindir" *conf*)))
			 (when (string-equal "lisp" (pathname-type load-file))
			   (setf file load-file)
			   (prepare-plugin
			    (with-open-file (stream load-file)
			      (read-plugin stream)))))
		       (setf file nil)
		       (dolist (plugin *plugins*)
			 (load-plugin plugin (connection message))))
		   (error (e) (setf err e))
		   (plugin-exists (c) (declare (ignore c))))
		 (if err
		     (reply-to message (format nil "ERROR: In ~a: ~a" (pathname-name file) err))
		     (reply-to message "Done."))))))