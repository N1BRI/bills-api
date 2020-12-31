;;; common api funcs 

;;; m a c r o s

(defmacro str-assoc(key lst)
  `(assoc ,key ,lst :test #'string=))

;; this is to handle pre-flight request for cors
(defmacro @options-route (path fn-name)
  `(easy-routes:defroute ,fn-name
       (,path :method :options
	      :decorators
	      (@enable-cors @json))()
     (setf (hunchentoot:header-out "Access-Control-Allow-Methods") "OPTIONS")))

;;returns body of request as an alist or nil 
(defun request-json-to-alist()
  (let ((raw-body (hunchentoot:raw-post-data :force-text t)))
    (handler-case
	(jonathan:parse raw-body :as :alist)
      (error () nil))))
    

;;; d e c o r a t o r s

;;set response output to application/json
(defun @json (next)
  (setf (hunchentoot:content-type*) "application/json")
  (funcall next))

;;enable cors
(defun @enable-cors (next)
  (setf (hunchentoot:header-out "Access-Control-Allow-Origin") "*")
  (setf (hunchentoot:header-out "Access-Control-Allow-Headers") "x-requested-with, Content-Encoding, Content-Type, origin, authorization, accept, client-security-token")
  (funcall next))
