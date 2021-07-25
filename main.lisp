(ffi:require js:react "react")
(ffi:require js:react-dom "react-dom")

(in-package :portal-plurality)

(define-react-component <app> ()
  (jsx (:h1 () "")))

(js:console.log (ffi:object :a 3 :b 4))

(setup '<app> "root" :remote-eval t)
