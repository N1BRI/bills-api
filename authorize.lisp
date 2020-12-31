(defparameter *secret* (uiop:read-file-lines #p"~/.quicklisp/local-projects/bills-api/config/settings.config"))
(defvar *key* (ironclad:ascii-string-to-byte-array (first *secret*)))

;;jwt funcs
(defun build-token(user-id)
  (jose:encode :hs256 *key* `(("user-id" . ,user-id)
			 ("exp" . ,(+ (get-universal-time) 3600)))))

(defun decode-token(token)
  (handler-case
      (let ((token (jose:decode :hs256
			   *key*
			   (subseq token (length "Bearer "))))) ;; remove "Bearer " from token
	(let ((exp (str-assoc "exp" token)))
	  (if (< (rest exp) (get-universal-time))
	      (error "token is expired")
	      token)))
    
    (error () nil)))

(defun authorized()
  (decode-token
   (hunchentoot:header-in* :authorization)))

;;authorization endpoint
(@options-route "/authorize/" :auth-ops)
(easy-routes:defroute
    authorize ("/authorize/" :method :post :decorators(@enable-cors @json))()
  (let ((payload (request-json-to-alist)))
    (let
	((user (cdr (str-assoc "username" payload)))
	 (pass (cdr (str-assoc "password" payload)))
	 (res nil)
	 (user-id nil))
      (connect-db)
      (handler-case 
	  (setf user-id
		(postmodern:query
		 (:select 'id
			  :from 'users
			  :where
			  (:and
			   (:= 'username user)
			   (:= 'password pass))):single))
	(error()
	      (setf (hunchentoot:return-code*) 500)
	      (setf res '(:|message| "error on select"))
	      (jonathan:to-json res)))
        (if user-id
	    (progn
	      (setf (hunchentoot:return-code*) hunchentoot:+http-created+)
	      (jonathan:to-json `(:|bearerToken| ,(build-token user-id))))
	    (progn
	      (setf (hunchentoot:return-code*) hunchentoot:+http-authorization-required+)
	      (jonathan:to-json '(:|message| "authentication failed")))))))
