(in-package :portal-plurality)

(progn
  (defparameter char-controller (create-script "charcontroller"))
  (add-attribute char-controller "speed" :type #j"number" :default 4)
  (add-attribute char-controller "jumpForce" :type #j"number" :default 5)

  (defprotomethod initialize char-controller (_)
    (js-setf (js:this "groundCheckRay") (vec3 :x 0 :y -0.5 :z 0)
             (js:this "rayEnd") (vec3)
             (js:this "onGround") t
             (js:this "jumping") nil))

  (defprotomethod move char-controller (direction)
    (if (and (ffi:ref js:this "onGround")
             (not (ffi:ref js:this "jumping")))
        (let ((tmp (vec3))
              (len (ffi:ref direction "length")))
          (if (> len 0)
              (progn
                ((ffi:ref 
                  ((ffi:ref tmp cross) (ffi:ref js:this "groundNormal") direction)
                  cross) tmp (ffi:ref js:this "groundNormal"))
                ((ffi:ref (ffi:ref tmp normalize) scale) (* len (ffi:ref js:this speed)))))
          (js-setf (js:this "entity" "rigidbody" "linearVelocity") tmp))))

  (defprotomethod jump char-controller (_)
    (if (and (ffi:ref js:this "onGround")
             (not (ffi:ref js:this "jumping")))
        (progn
          ((ffi:ref js:this "entity" "rigidbody" "applyImpulse") 0 (ffi:ref js:this "jumpForce") 0)
          (js-setf (js:this "onGround") nil
                   (js:this "jumping") t)
          (js:set-timeout ((ffi:ref (lambda () (js-setf (js:this "jumping") nil))
                                    "bind") js:this) 500)))))

(add-scripts box '("charcontroller"))
(remove-scripts box '("charcontroller"))
(js:console.log (ffi:ref char-controller "attributes"))
(js:console.log #jbox)


(js:console.log (vec3 :x 4 :y 5 :z 6))
(js:console.log char-controller)


