(defparameter +API-SERVER+ nil)

(defun startup (&optional (port 4242))
  (setf +API-SERVER+ (hunchentoot:start (make-instance 'easy-routes:routes-acceptor :port port))))
