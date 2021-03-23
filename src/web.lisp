(in-package :cl-user)
(defpackage imageboard.web
  (:use :cl
        :caveman2
        :imageboard.config
        :imageboard.view
        :imageboard.db
        :datafly
        :sxql)
  (:export :*web*))
(in-package :imageboard.web)

;; for @route annotation
(syntax:use-syntax :annot)

;;
;; Application

(defclass <web> (<app>) ())
(defvar *web* (make-instance '<web>))
(clear-routing-rules *web*)

;; static files


;;
;; Routing rules

(defroute "/" ()
  (render #P"index.html"))

(defroute "/imageboard" ()
  (render #P"imageboard.html"
		  (list :posts (mito:select-dao 'post
						 (sxql:where (:= :parent_id 1))))))

(defroute ("/imageboard" :method :POST) (&key _parsed)
  (format t "~S" (cdr (assoc "content" _parsed :test #'string=)))
  (let ((content (cdr (assoc "content" _parsed :test #'string=)))
		(name (cdr (assoc "name" _parsed :test #'string=))))
	(mito:insert-dao (if (string/= "" name)
						 (make-instance 'post :content content
											  :parent_id 1
											  :name name)
						 (make-instance 'post :content content
											  :parent_id 1))))
  (render #P"imageboard.html"
		  (list :posts (mito:select-dao 'post
						 (sxql:where (:= :parent_id 1))))))

;;
;; Error pages

(defmethod on-exception ((app <web>) (code (eql 404)))
  (declare (ignore app))
  (merge-pathnames #P"_errors/404.html"
                   *template-directory*))
