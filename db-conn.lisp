;;db connection string
(defparameter *conn* (uiop:read-file-lines #p"~/.quicklisp/local-projects/bills-api/config/dbconn.config"))

;;connection to postgres
(defun connect-db()
  (unless postmodern:*database*
    (postmodern:connect-toplevel (first *conn*)(second *conn*)
				 (third *conn*)(fourth *conn*))))
