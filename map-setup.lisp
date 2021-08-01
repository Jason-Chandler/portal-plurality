(in-package :portal-plurality)

(load-static "./files/assets/portal-maze.glb" t)

(defparameter ent (ffi:new (ffi:ref "pc.Entity")))
((ffi:ref js:pc app root add-child) ent)

(make-portal (vec3 :x 5 :y 2 :z 0) (vec3 :x 5 :y 80 :z 0) 'x)

(add-mesh-collision ent "./files/assets/testbox.glb")

((ffi:ref ent add-component) #j"rigidbody")

(js:console.log ent)


(teleport)

(js-setf (*lamp-color* r) 0
         (*lamp-color* g) 1
         (*lamp-color* b) 1
         (*lamp-color* a) 1)
(defparameter *lamp-color* (ffi:new (ffi:ref "pc.Color") 1 1 1))

(defun add-player-headlamp (&rest _)
  (let ((ent (ffi:new (ffi:ref "pc.Entity"))))
    (js-setf (ent position) (ffi:ref player position))
    ((ffi:ref player add-child) ent)
    ((ffi:ref ent add-component) #j"light")
    (js-setf (ent light color) (ffi:new (ffi:ref "pc.Color") 1 1 1)
             (ent light type) #j"omni")))

((ffi:ref js:pc app on) #j"update" 
                            (lambda (dt &rest _) 
                              (js-setf (js:this position) (ffi:ref player position)))
                            ent)

(defparameter en (ffi:new (ffi:ref "pc.Entity")))

(ffi:set (ffi:ref en position) (ffi:ref player position))
((ffi:ref js:pc app root add-child) en)
((ffi:ref en add-component) #j"light")
(ffi:set (ffi:ref en light type) #j"omni")

(js:console.log player)
(js:console.log (ffi:ref player position))
(add-player-headlamp)