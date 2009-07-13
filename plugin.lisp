(in-package :thune)

(defparameter *plugins* ()
  "The list of all prepared, but not necessarily active, plugins.")

(defun prepare-plugin (plugin)
  "Inserts PLUGIN into the global list of available plugins, replacing any plugin with the same name."
  (let ((old (car (member plugin *plugins* :test #'plugin-equal))))
    (if old
	(progn
	  (warn 'plugin-exists)
	  (nsubstitute plugin old *plugins* :test #'plugin-equal))
	(push plugin *plugins*))))

(defparameter *connection-plugin-hooks* ()
  "An alist associating connections with alists associating plugins with their cl-irc hooks.")

(defun init-plugin-system (connection)
  (push (cons connection nil) *connection-plugin-hooks*))

(defun cleanup-plugin-system (connection)
  (setf *connection-plugin-hooks*
	(remove-if #'(lambda (cons) (eq (car cons) connection))
		   *connection-plugin-hooks*)))

(defclass plugin ()
  ((name
    :initarg :name
    :initform (error "Plugins must have a name!")
    :reader plugin-name
    :documentation "Unique identifier.")
   (hooks
    :initarg :hooks
    :accessor plugin-hooks)
   (action
    :initarg :action
    :accessor plugin-action)))


(defgeneric plugin-equal (x y)
  (:documentation "Tests plugins X and Y for equality."))

;; Is a generic necessary here?
(defgeneric load-plugin (plugin connection)
  (:documentation "Loads PLUGIN into the bot, attaching hooks to CONNECTION."))

(defgeneric run-plugin (plugin message)
  (:documentation "Executes PLUGIN."))


(define-condition plugin-exists (warning)
  ((name
    :initarg :name
    :reader name)))


(defmethod plugin-equal ((x plugin) (y plugin))
  (string-equal (plugin-name x) (plugin-name y)))

(defmethod load-plugin ((plugin plugin) connection)
  "Attaches a plugin's hooks."
  (let* ((hook-func #'(lambda (message) (run-plugin plugin message)))
	 (hook-alist (assoc connection *connection-plugin-hooks*))
	 (old (assoc plugin (cdr hook-alist) :test #'plugin-equal)))
    (if old
	(progn
	  (warn 'plugin-exists :name (plugin-name plugin))
	  (dolist (class (plugin-hooks (car old)))
	    (remove-hook connection class (cdr old)))
	  (setf (car old) plugin)
	  (setf (cdr old) hook-func))
	(progn
	  (push (cons plugin hook-func) (cdr hook-alist))))
    (dolist (class (plugin-hooks plugin))
       (add-hook connection class hook-func))))

(defun unload-plugin (plugin connection)
  "Detaches a plugin's hooks."
  (let* ((hook-alist (assoc connection *connection-plugin-hooks*))
	 (old (assoc plugin (cdr hook-alist) :test #'plugin-equal)))
    (when old
      (progn
	(dolist (class (plugin-hooks (car old)))
	  (remove-hook connection class (cdr old)))
	(setf (cdr hook-alist) (remove old (cdr hook-alist)
					 :test #'plugin-equal))))))

(defmethod run-plugin ((plugin plugin) message)
  (funcall (plugin-action plugin) message))

(defun read-plugin (stream)
  (let* ((raw (let ((*package* (find-package :thune)))
		(read stream)))
	 (class (first raw))
	 (definition (rest raw)))
    (unless (subtypep class 'plugin)
      ;; TODO: More appropriate error
      (error 'type-error :datum class :expected-type 'plugin))
    (apply #'make-instance class definition)))