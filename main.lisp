(ffi:require js:react "react")
(ffi:require js:react-dom "react-dom")

(defpackage :portal-plurality
  (:use :cl :valtan.react-utilities))
(in-package :portal-plurality)

(define-react-component <app> ()
  (jsx (:h1 () "")))

(setup '<app> "root" :remote-eval t)
