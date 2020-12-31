

;;; add routes for preflight options 
(@options-route "/:username/bills/" :bill-ops)
(@options-route "/:username/bills/:bill-id" :bill-id-ops)


;;[GET] all bills
(easy-routes:defroute all-bills
    ("/:username/bills/" :method :get :decorators(@enable-cors @json))()
  (if (authorized)
    (progn
      (connect-db)
      (let ((res '()))
	 (handler-case 
	    (postmodern:doquery
		(:select 'name 'due_date 'autopaid 'owner 'amount 'balance 'id
			 :from 'bills
			 :where (:= 'owner username))
		(name due-date auto-paid owner amount balance id)
	      (push `( :|name| ,name
			:|dueDate| ,due-date
			:|isAutoPaid| ,auto-paid
			:|owner| ,owner
			:|amount| ,amount
			:|balance| ,balance
			:|id| ,id) res))
	    (error()
	      (setf (hunchentoot:return-code*) 500)
	      (setf res '(:|message| "error on get"))))
	 (jonathan:to-json res)))
    (progn ;; user is not authorized -- token is junk
	  (setf (hunchentoot:return-code*) 401)
	  (jonathan:to-json '(:|message| "User is unauthorized")))))

;;[GET] A single bill's details
(easy-routes:defroute get-bill
    ("/:username/bills/:bill-id" :method :get :decorators(@enable-cors @json))()
  (if (authorized)
    (progn
      (connect-db)
      (let ((res nil))
	(handler-case 
	    (postmodern:doquery
		(:select 'name 'due_date 'autopaid 'owner 'amount 'balance
			 :from 'bills
			 :where (:and (:= 'owner username)(:= 'id bill-id)))
		(name due-date auto-paid owner amount balance)
	      (setf res`(:|name| ,name
			  :|dueDate| ,due-date
			  :|isAutoPaid| ,auto-paid
			  :|owner| ,owner
			  :|amount| ,amount
			  :|balance| ,balance)))
	  (error()
	      (setf (hunchentoot:return-code*) 500)
	      (setf res  '(:|message| "error on get"))))
	(jonathan:to-json res)))
    (progn ;; user is not authorized
      (setf (hunchentoot:return-code*) 401)
      (jonathan:to-json '(:|message| "User is unauthorized")))))

;;[POST] create a new bill
(easy-routes:defroute create-bill
    ("/:username/bills/" :method :post :decorators(@enable-cors @json))()
  (if (authorized)
    (let ((payload (request-json-to-alist)))
      (progn
	(let ((res nil)
	      (name (cdr (str-assoc "name" payload)))
	      (due-date (cdr (str-assoc "dueDate" payload)))
	      (autopaid (cdr (str-assoc "isAutoPaid" payload)))
	      (owner (cdr (str-assoc "owner" payload)))	
	      (amount (cdr (str-assoc "amount" payload)))
	      (balance (cdr (str-assoc "balance" payload))))
	  (connect-db)
	  (handler-case 
	      (postmodern:query
		  (:insert-into 'bills :set
				'name name
				'due_date due-date
				'autopaid autopaid
				'owner owner
				'amount amount
				'balance balance))
	    (error()
	      (setf (hunchentoot:return-code*) hunchentoot:+http-bad-request+)
	      (setf res '(:|message| "error on save"))))
	  (when (null res)
	      (setf (hunchentoot:return-code*) hunchentoot:+http-ok+)
	      (setf res `(:|message| ,(format nil "Success"))))
	  (jonathan:to-json res))))
    (progn ;; user is not authorized
      (setf (hunchentoot:return-code*) 401)
      (jonathan:to-json '(:|message| "User is unauthorized")))))

;;[PUT] update an existing bill
(easy-routes:defroute update-bill
    ("/:username/bills/:bill-id" :method :put :decorators(@enable-cors @json))()
  (if (authorized)
      (progn
	(let ((payload (request-json-to-alist)))
	    (let ((res nil)
		  (name (cdr (str-assoc "name" payload)))
		  (due-date (cdr (str-assoc "dueDate" payload)))
		  (autopaid (cdr (str-assoc "isAutoPaid" payload)))
		  (owner (cdr (str-assoc "owner" payload)))	
		  (amount (cdr (str-assoc "amount" payload)))
		  (balance (cdr (str-assoc "balance" payload))))
	      (connect-db)
	      (handler-case 
		  (postmodern:query
		   (:update 'bills
			    :set
			    'name name
			    'due_date due-date
			    'autopaid autopaid
			    'owner owner
			    'amount amount
			    'balance balance
			    :where (:= 'id bill-id)))
		(error()
		  (setf (hunchentoot:return-code*) hunchentoot:+http-bad-request+)
		  (setf res '(:|message| "error on update"))))
	      (when (null res)
		  (setf (hunchentoot:return-code*) hunchentoot:+http-ok+)
		  (setf res `(:|message| ,(format nil "Success"))))
	      (jonathan:to-json res))))
      (progn ;; user is not authorized
	(setf (hunchentoot:return-code*) 401)
	(jonathan:to-json '(:|message| "User is unauthorized")))))

;; [DELETE] delete a bill
(easy-routes:defroute delete-bill
    ("/:username/bills/:bill-id" :method :delete :decorators(@enable-cors @json))()
  (if (authorized)
    (progn
      (connect-db)
      (let ((res '()))
	 (handler-case 
	    (postmodern:query
		(:delete-from 'bills
			 :where (:and (:= 'id bill-id)
				      (:= 'owner username))))
	    (error()
	      (setf (hunchentoot:return-code*) 500)
	      (setf res '(:|message| "error on delete"))))
	 (when (null res)
		  (setf (hunchentoot:return-code*) hunchentoot:+http-ok+)
		  (setf res `(:|message| ,(format nil "~a Successfully deleted bill" username))))
	 (jonathan:to-json res)))
    (progn
	(setf (hunchentoot:return-code*) 401)
	(jonathan:to-json '(:|message| "User is unauthorized")))))
