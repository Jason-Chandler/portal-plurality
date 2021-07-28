(ffi:require js:react "react")
(ffi:require js:react-dom "react-dom")

(in-package :portal-plurality)

(define-react-component <app> ()
  (jsx (:h1 () "")))

(js:console.log (ffi:object :a 3 :b 4))

(defparameter box (find-by-name "Box"))
(add-component box "script")

(js-setf (box rigidbody mass) 3)

(add-scripts box '("charcontroller" 
                   "firstpersoncamera" 
                   "keyboardinput" 
                   "mouseinput" 
                   "reset"))

(setup '<app> "root" :remote-eval t)
