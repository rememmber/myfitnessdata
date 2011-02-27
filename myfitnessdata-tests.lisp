(defpackage :myfitnessdata-tests
  (:use :common-lisp))
(in-package :myfitnessdata-tests)

(load "myfitnessdata.lisp")
(ql:quickload '("lisp-unit"))

(defmacro run-tests-and-quit (&body tests)
  `(if (lisp-unit:run-tests ,@tests)
       (sb-ext:quit :unix-status 1)
     (sb-ext:quit :unix-status 0)))

(defmacro define-test-with-cookie-jar (test-name cookie-domain cookie-name test)
  `(lisp-unit:define-test
    ,test-name
    (let* ((cookie-jar (make-instance 'drakma:cookie-jar))
	   (cookie ,(if (and cookie-name cookie-domain)
			`(make-instance 'drakma:cookie :name ,cookie-name :domain ,cookie-domain)
		      `nil)))
      (if cookie
	  (setf (drakma:cookie-jar-cookies cookie-jar) (list cookie)))
      ,test)))

(define-test-with-cookie-jar
  logged-in-nil-when-no-cookies
  nil
  nil
  (lisp-unit:assert-false (myfitnessdata:logged-in? cookie-jar)))

(define-test-with-cookie-jar
  logged-in-nil-when-cookies-from-wrong-domain
  "www.example.com" 
  "known_user" 
  (lisp-unit:assert-false (myfitnessdata:logged-in? cookie-jar)))

(define-test-with-cookie-jar 
  logged-in-t-when-cookies-from-right-domain
  "www.myfitnesspal.com" 
  "known_user"
  (lisp-unit:assert-true (myfitnessdata:logged-in? cookie-jar)))

(lisp-unit:define-test 
 make-csv-from-list
 (let ((list '(("1/1/2000" "79.2") ("2/1/2000" "23.4"))))
   (lisp-unit:assert-equal (format nil "\"1/1/2000\",\"79.2\"~%\"2/1/2000\",\"23.4\"~%")
			   (myfitnessdata:make-csv list))))

(run-tests-and-quit
 logged-in-nil-when-no-cookies
 logged-in-nil-when-cookies-from-wrong-domain
 logged-in-t-when-cookies-from-right-domain
 make-csv-from-list)