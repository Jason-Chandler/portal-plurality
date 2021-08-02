(in-package :portal-plurality)

(progn
  (make-portal (vec3 :x -205 :y 2 :z -101) (vec3 :x -126.90 :y 2 :z -76.73) 'z)
  (make-portal (vec3 :x -143.4 :y 2 :z -121.5) (vec3 :x -311.00 :y 2 :z -136.58) 'z)
  (make-portal (vec3 :x -138.8 :y 2 :z -169.79) (vec3 :x -126.90 :y 2 :z -81.73) 'x)
  (make-portal (vec3 :x -293.79 :y 2 :z -4.3) (vec3 :x -96.69 :y 2 :z -204.40) 'x)
  (make-portal (vec3 :x -27.50 :y 2 :z -43.09) (vec3 :x -45.28 :y 2 :z -223.4) 'x)
  (make-portal (vec3 :x -126.90 :y 2 :z -81.73) (vec3 :x -96.69 :y 2 :z -204.40)  'z)
  (make-portal (vec3 :x -40.28 :y 2 :z -223.4) (vec3 :x -138.4 :y 2 :z -121.5) 'x)
  (make-portal (vec3 :x -96.69 :y 2 :z -194.40) (vec3 :x -27.50 :y 2 :z -38.09) 'z)
  (make-portal (vec3 :x -311.00 :y 2 :z -137.58) (vec3 :x -133.8 :y 2 :z -169.79) 'x)
  (make-portal (vec3 :x -180.03 :y 2 :z -67.56) (vec3 :x -153.68 :y 20.4 :z -305.58) 'z) ;; victory
  (make-portal (vec3 :x -178.73 :y 2 :z -191.01) (vec3 :x -143.4 :y 2 :z -116.5) 'z))

(defparameter key (load-static "./files/assets/key.glb" t))

((ffi:ref key rigidbody teleport) (vec3 :x -162.73 :y 19.42 :z -289))


((ffi:ref key collision on) #j"collisionstart" (lambda (ent &rest _)
                                                 (js:alert #j"You found the key! You win!")
                                                 (define-react-component <app> ()
                                                 (jsx (:h1 () "YOU FOUND THE KEY! YOU WIN!")))
                                                 ((ffi:ref js:pc app destroy))) key)

