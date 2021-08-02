(ffi:require js:react "react")
(ffi:require js:react-dom "react-dom")

(in-package :portal-plurality)

(define-react-component <app> ()
  (jsx (:h1 () "")))

(defparameter player (find-by-name "PLAYER"))
(add-component player "script")
(defparameter light (find-by-name "LIGHT"))
(js-setf (light light shadow-distance) 100
         (light light shadow-resolution) 2048)

(js-setf (player rigidbody mass) 1
         (player rigidbody angular-factor) (ffi:ref js:pc -vec3 -z-e-r-o)
         (player rigidbody restitution) 0.1)

(add-scripts player '("charcontroller" 
                      "firstpersoncamera" 
                      "keyboardinput" 
                      "mouseinput" 
                      "reset"))

(load-static "./files/assets/portal-maze.glb" t)

(defun add-player-headlamp (&rest _)
  (let ((ent (ffi:new (ffi:ref "pc.Entity") #j"headlamp")))
    (js-setf (ent position) (ffi:ref player position))
    ((ffi:ref player add-child) ent)
    ((ffi:ref ent add-component) #j"light")
    (js-setf (ent light color) (ffi:new (ffi:ref "pc.Color") 1 1 1)
             (ent light type) #j"omni")))

(add-player-headlamp)

(defparameter headlamp ((ffi:ref js:pc app root find-by-name) #j"headlamp"))

(let ((r 1)
      (g 0)
      (b 0)
      (inc-r t)
      (inc-g nil)
      (inc-b nil))
    (defun generate-color ()
      (cond
        ((and inc-r (not inc-b) (< g 1))
         (progn
           (incf g 0.01)
           (setf inc-g t)))
        ((and inc-g (> r 0)) (progn 
                               (setf inc-r nil)
                               (decf r 0.01)))
        ((and inc-g (< b 1)) (progn
                   (incf b 0.01)
                   (setf inc-b t)))
        ((and inc-b (> g 0)) (progn 
                               (setf inc-g nil)
                               (decf g 0.01)))
        ((and inc-b (< r 1)) (progn 
                   (incf r 0.01)
                   (setf inc-r t)))
        ((and inc-r (> b 0)) (progn 
                   (decf b 0.01)))
        (t (setf inc-b nil)))
      (ffi:new (ffi:ref "pc.Color") r g b)))

(add-to-update 'color (lambda (dt)
                        (js-setf (headlamp light color) (generate-color))))


(setup '<app> "root" :remote-eval t)
