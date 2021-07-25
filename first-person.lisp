(in-package :portal-plurality)

(progn
  (defparameter char-controller (create-script "charcontroller"))
  (add-attribute char-controller #j"speed" :type #j"number" :default 4)
  (add-attribute char-controller #j"jumpForce" :type #j"number" :default 5))


(js:console.log (ffi:ref char-controller "attributes"))

(js:console.log (vec3 :x 4 :y 5 :z 6))

(js:console.log (find-by-name "Box"))