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
                                    "bind") js:this) 500))))

  (defprotomethod update char-controller (dt)
    (let ((pos ((ffi:ref js:this "entity" "getPosition"))))
      ((ffi:ref js:this "rayEnd" "add2") pos (ffi:ref js:this "groundCheckRay"))
      (let ((result ((ffi:ref js:this "app" "systems" "rigidbody" "raycastFirst") pos (ffi:ref js:this "rayEnd"))))
          (js-setf (js:this "onGround") result)
          (if result
              ((ffi:ref js:this "groundNormal" "copy") (ffi:ref result "normal"))))))

  (defparameter fps-cam (create-script "firstpersoncamera"))
  
  (add-attribute fps-cam "camera" 
                 :type #j"entity"
                 :title #j"camera"
                 :description #j"Camera for fps view. Should be child of script's parent entity")
  
  (defprotomethod initialize fps-cam (_)
    (let ((app (ffi:ref js:this "app")))
      (if (not (ffi:ref js:this "camera"))
          (progn
            (js-setf (js:this "camera") (new "Entity" #j"fps camera"))
            ((ffi:ref js:this "camera" "addComponent") "camera")
            ((ffi:ref js:this "entity" "addChild") (ffi:ref js:this "camera"))))
      (js-setf (js:this "x") (vec3)
               (js:this "z") (vec3)
               (js:this "heading") (vec3)
               (js:this "magnitude") (new "Vec2")
               (js:this "azimuth") 0
               (js:this "elevation") 0
               (js:this "camera" "camera" "enabled") t)
      (let ((temp ((ffi:ref js:this "camera" "forward" "clone"))))
        (js-setf (temp "y") 0)
        ((ffi:ref temp "normalize"))
        (js-setf (js:this "azimuth") (* ((ffi:ref "Math" "atan2") (- (ffi:ref temp "x"))
                                                                  (- (ffi:ref temp "z")))
                                        (/ 180 (ffi:ref "Math" "PI"))))
        (let ((rot ((ffi:ref (new "Mat4")) "setFromAxisAngle" (ffi:ref js:pc "Vec3" "UP")
                                           (- (ffi:ref js:this "azimuth")))))
          (js-setf (js:this elevation) (* ((ffi:ref "Math" atan) (ffi:ref temp "y") (ffi:ref temp "z"))
                                          (/ 180 (ffi:ref "Math" "PI"))))
          (js-setf (js:this "forward") 0
                   (js:this "strafe") 0
                   (js:this "jump") nil
                   (js:this "cnt") 0))))))

(add-scripts box '("charcontroller"))
(remove-scripts box '("charcontroller"))
(js:console.log (ffi:ref char-controller "attributes"))
(js:console.log #jbox)


(js:console.log (vec3 :x 4 :y 5 :z 6))
(js:console.log char-controller)


