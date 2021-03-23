(in-package :cl-user)
(defpackage imageboard.db
  (:use :cl)
  (:import-from :imageboard.config
                :config)
  (:import-from :mito
                :*connection*)
  (:import-from :cl-dbi
                :connect-cached)
  (:export :connection-settings
           :db
           :with-connection
		   :post))
(in-package :imageboard.db)

(mito:connect-toplevel :sqlite3 :database-name "imageboard")

(defclass post ()
  ((content :col-type (:varchar 4098)
			:initarg :content
			:accessor post-content)
   (parent_id :col-type :integer
			  :initarg :parent-id
			  :accessor post-parent-id)
   (tripcode :col-type (or (:varchar 128) :null)
			 :initarg :tripcode
			 :accessor post-tripcode)
   (attachment :col-type (or (:varchar 512) :null)
			   :initarg :attachment
			   :accessor post-attachment)
   (name :col-type (:varchar 32)
		 :initarg :name
		 :initform "Anonymous"
		 :accessor post-name))
  (:metaclass mito:dao-table-class))

(defclass thread ()
  ()
  (:metaclass mito:dao-table-class))

(mito:ensure-table-exists 'post)
(mito:ensure-table-exists 'thread)

(defun add-thread ()
  (mito:insert-dao (make-instance 'thread)))

(defun add-test-post ()
  (mito:insert-dao (make-instance 'post :content "pony"
										:parent_id 1
										:attachment "https://smilebasicsource.com/api/File/raw/6373")))

(defun get-posts (id)
  (mito:select))

;; (map 'list (lambda (x) (post-content x))
;; 	 (mito:select-dao 'post
;; 	   (sxql:where (:= :parent_id 1))))

(defun connection-settings (&optional (db :maindb))
  (cdr (assoc db (config :databases))))

(defun db (&optional (db :maindb))
  (apply #'connect-cached (connection-settings db)))

(defmacro with-connection (conn &body body)
  `(let ((*connection* ,conn))
     ,@body))
