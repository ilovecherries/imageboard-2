(in-package :cl-user)
(defpackage imageboard.web
  (:use :cl
        :caveman2
        :imageboard.config
        :imageboard.view
        :imageboard.db
        :datafly
        :sxql)
  (:import-from :cl-markdown :markdown)
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

(defroute "*/" ()
  (render #P"index.html"))

(defun render-posts (thread-id)
  "Apply markdown rendering to imageboard posts from all posts
in THREAD-ID."
  (list :posts (mito:select-dao 'post
		 (sxql:where (:= :parent_id thread-id)))))
  ;; disabled until I can find a way to trim HTML from the renderer
  ;; (flet ((markdown-render (post)
  ;; 	   "Renders the markdown of a post and returns the post."
  ;; 	   (setf (imageboard.db::post-content post)
  ;; 		 (with-output-to-string (s)
  ;; 		   (markdown (imageboard.db::post-content post) :stream s)))
  ;; 	   post))
  ;;   (list :posts (map
  ;; 		  'list
  ;; 		  #'markdown-render
  ;; 		  (mito:select-dao 'post
  ;; 		    (sxql:where (:= :parent_id 1)))))))

(defroute "*/imageboard" ()
  (render #P"imageboard.html"
	  (render-posts 1)))

(defroute ("*/imageboard" :method :POST) (&key _parsed)
  (let ((content (cdr (assoc "content" _parsed :test #'string=)))
	(name (cdr (assoc "name" _parsed :test #'string=)))
	(image (cdr (assoc "image" _parsed :test #'string=))))
    (when (or (string/= "" content)
	      (string/= "" image))
      (mito:insert-dao 
       (let ((to-send (make-instance 'post :content content
					   :parent_id 1)))
	 (when (string/= "" name)
	   (setf (imageboard.db::post-name to-send) name))
	 (when (string/= "" image)
	   (setf (imageboard.db::post-attachment to-send) image))
	 to-send))))
  (render #P"imageboard.html"
	  (render-posts 1)))

;;
;; Error pages

(defmethod on-exception ((app <web>) (code (eql 404)))
  (declare (ignore app))
  (merge-pathnames #P"_errors/404.html"
                   *template-directory*))
