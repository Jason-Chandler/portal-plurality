(in-package :portal-plurality)

(progn
  (defparameter char-controller (create-script "charcontroller"))
  (add-attribute char-controller #j"speed" :type #j"number" :default 4)
  (add-attribute char-controller #j"jumpForce" :type #j"number" :default 5)

  (defprotomethod initialize char-controller (_)
    (js-setf (js:this "groundCheckRay") (vec3 :x 0 :y -0.5 :z 0)
             (js:this "rayEnd") (vec3)
             (js:this "onGround") t
             (js:this "jumping") nil))

  (defprotomethod move char-controller (direction)
    (if (and (ffi:ref (js:this "onGround"))
             (not (ffi:ref (js:this "jumping"))))
        (let ((tmp (vec3))
              (len (ffi:ref (direction "length"))))
          (if (> len 0)
              (progn
                ()))))))

(add-scripts box '("charcontroller"))
(remove-scripts box '("charcontroller"))
(js:console.log (ffi:ref char-controller "attributes"))
(js:console.log box)


(js:console.log (vec3 :x 4 :y 5 :z 6))
(js:console.log char-controller)


