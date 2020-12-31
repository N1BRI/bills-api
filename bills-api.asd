;;;; bills-api.asd

(asdf:defsystem #:bills-api
  :description "A basic bills-tracking RESTful API"
  :author "brian beegan <brianbeegan@protonmail.com"
  :license  "MIT License"
  :version "1.0.0"
  :serial t
  :depends-on (#:hunchentoot #:postmodern #:easy-routes #:jonathan #:jose #:ironclad)
  :components ((:file "package")
	       (:file "api-common")
	       (:file "db-conn")
	       (:file "authorize")
	       (:file "bills")
	       (:file "server")))
