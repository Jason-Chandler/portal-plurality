(in-package :portal-plurality)

;; This file is an abomination and overuses ffi. Will fix it someday.
(defparameter char-controller (create-script "charcontroller"))
(add-attribute char-controller "speed" :type #j"number" :default 25)
(add-attribute char-controller "jumpForce" :type #j"number" :default 5)

(defprotomethod initialize char-controller (_)
  (js-setf (js:this "groundCheckRay") (vec3 :x 0 :y -1.2 :z 0)
           (js:this "rayEnd") (vec3)
           (js:this "groundNormal") (vec3)
           (js:this "onGround") t
           (js:this "jumping") nil))

(defprotomethod move char-controller (direction)
  (if (and (ffi:ref js:this "onGround")
           (not (ffi:ref js:this "jumping")))
      (let ((tmp (vec3))
            (len ((ffi:ref direction "length"))))
        (if (> len 0)
            (progn
              ((ffi:ref 
                ((ffi:ref tmp cross) (ffi:ref js:this "groundNormal") direction)
                cross) tmp (ffi:ref js:this "groundNormal"))
              ((ffi:ref ((ffi:ref tmp normalize)) scale) (* len (ffi:ref js:this speed)))))
        (js-setf (js:this "entity" "rigidbody" "linearVelocity") tmp))))

(defprotomethod jump char-controller ()
  (if (and (not (eql (ffi:ref js:this "onGround") js:null))
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
      (if (not (ffi:ref js:this "jumping"))
          (#j:this:entity:rigidbody:applyForce (vec3 :x 0 :y -200 :z 0)))
      (if (not (eql  result js:null))
          ((ffi:ref js:this "groundNormal" "copy") (ffi:ref result "normal"))))))

(defparameter fps-cam (create-script "firstpersoncamera"))
  
(add-attribute fps-cam "camera" 
               :type #j"entity"
               :title #j"camera"
               :description #j"Camera for fps view. Should be child of script's parent entity")
  
(defprotomethod initialize fps-cam (_)
  (let ((app (ffi:ref js:this "app")))
    (if (eql (ffi:ref js:this "camera") js:null)
        (progn
          (js-setf (js:this "camera") (ffi:new (ffi:ref "pc.Entity") #j"fps camera"))
          ((ffi:ref js:this "camera" "addComponent") #j"camera")
          ((ffi:ref js:this "entity" "addChild") (ffi:ref js:this "camera"))))
    (js-setf (js:this "x") (vec3)
             (js:this "z") (vec3)
             (js:this "heading") (vec3)
             (js:this "magnitude") (ffi:new (ffi:ref "pc.Vec2"))
             (js:this "azimuth") 0
             (js:this "elevation") 0
             (js:this "camera" "camera" "enabled") t)
    (let ((temp ((ffi:ref js:this "camera" "forward" "clone"))))
      (js-setf (temp "y") 0)
      ((ffi:ref temp "normalize"))
      (js-setf (js:this "azimuth") (* ((ffi:ref #j:Math "atan2") (- 0 (ffi:ref temp "x"))
                                                                 (- 0 (ffi:ref temp "z")))
                                      (/ 180 (ffi:ref #j:Math "PI"))))
      (let ((rot ((ffi:ref (ffi:new (ffi:ref "pc.Mat4")) "setFromAxisAngle") (ffi:ref js:pc "Vec3" "UP")
                                                                             (- 0 (ffi:ref js:this "azimuth")))))
        ((ffi:ref rot "transformVector") (ffi:ref js:this "camera" "forward") temp)
        (js-setf (js:this "elevation") (* ((ffi:ref #j:Math "atan") (ffi:ref temp "y") (ffi:ref temp "z"))
                                          (/ 180 (ffi:ref #j:Math "PI"))))
        (js-setf (js:this "forward") 0
                 (js:this "strafe") 0
                 (js:this "canJump") nil
                 (js:this "cnt") 0)

        ((ffi:ref app "on") #j"firstperson:forward"
                            (lambda (val &rest _)
                              (js-setf (js:this "forward") val))
                            js:this)

        ((ffi:ref app "on") #j"firstperson:strafe"
                            (lambda (val &rest _)
                              (js-setf (js:this "strafe") val))
                            js:this)

        ((ffi:ref app "on") #j"firstperson:look"
                            (lambda (azimuth-delta elevation-delta &rest _)
                              (js-setf (js:this "azimuth") (+ (ffi:ref js:this "azimuth") azimuth-delta)
                                       (js:this "elevation") (+ (ffi:ref js:this "elevation") elevation-delta))
                              (js-setf (js:this "elevation") ((ffi:ref (ffi:ref js:pc "math") "clamp") (ffi:ref js:this "elevation")
                                                                                                       -90
                                                                                                       90)))
                            js:this)

        ((ffi:ref app "on") #j"firstperson:jump"
                            (lambda (&rest _)
                              (js-setf (js:this "canJump") t))
                            js:this)

        ((ffi:ref app "on") #j"firstperson:unlock"
                            (lambda (&rest _)
                              (funcall (ffi:ref app "mouse" "disablePointerLock")))
                            js:this)))))

(defprotomethod post-update fps-cam (dt)
  ((ffi:ref js:this "camera" "setEulerAngles") (ffi:ref js:this "elevation")
                                               (ffi:ref js:this "azimuth")
                                               0)
  ((ffi:ref js:this "z" "copy") (ffi:ref js:this "camera" "forward"))
  (js-setf (js:this "z" "y") 0)
  ((ffi:ref js:this "z" "normalize"))
  ((ffi:ref js:this "x" "copy") (ffi:ref js:this "camera" "right"))
  (js-setf (js:this "x" "y") 0)
  ((ffi:ref js:this "x" "normalize"))
  ((ffi:ref (ffi:ref js:this "heading") "set") 0 0 0)

  (if (not (zerop (ffi:ref js:this "forward")))
      (progn
        ((ffi:ref (ffi:ref js:this "z") "scale") (ffi:ref js:this "forward"))
        ((ffi:ref (ffi:ref js:this "heading") "add") (ffi:ref js:this "z"))))

  (if (not (zerop (ffi:ref js:this "strafe")))
      (progn
        ((ffi:ref (ffi:ref js:this "x") "scale") (ffi:ref js:this "strafe"))
        ((ffi:ref (ffi:ref js:this "heading") "add") (ffi:ref js:this "x"))))

  (if (> ((ffi:ref (ffi:ref js:this "heading") "length")) 0.0001)
      (progn
        ((ffi:ref (ffi:ref js:this "magnitude") "set") (ffi:ref js:this "forward") (ffi:ref js:this "strafe"))
        ((ffi:ref ((ffi:ref (ffi:ref js:this "heading") "normalize")) "scale") ((ffi:ref (ffi:ref js:this "magnitude") "length")))))

  (if (ffi:ref js:this "canJump")
      (progn
        ((ffi:ref js:this "entity" "script" "charcontroller" "jump"))
        (js-setf (js:this "canJump") nil)))

  ((ffi:ref (ffi:ref js:this "entity" "script" "charcontroller") "move") (ffi:ref js:this "heading"))

  (let ((pos ((ffi:ref js:this "camera" "getPosition"))))
    ((ffi:ref js:this "app" "fire") #j"cameramove" pos)))

(defparameter keyboard-input (create-script "keyboardinput"))

(defprotomethod initialize keyboard-input (_)
  (let* ((app (ffi:ref js:this "app"))
         (update-movement (lambda (key-code value)
                            (case key-code
                              (27 ((ffi:ref app "fire") #j"firstperson:unlock"))
                              (38 ((ffi:ref app "fire") #j"firstperson:forward" value))
                              (87 ((ffi:ref app "fire") #j"firstperson:forward" value))
                              (40 ((ffi:ref app "fire") #j"firstperson:forward" (- value)))
                              (83 ((ffi:ref app "fire") #j"firstperson:forward" (- value)))
                              (37 ((ffi:ref app "fire") #j"firstperson:strafe" (- value)))
                              (65 ((ffi:ref app "fire") #j"firstperson:strafe" (- value)))
                              (39 ((ffi:ref app "fire") #j"firstperson:strafe" value))
                              (68 ((ffi:ref app "fire") #j"firstperson:strafe" value)))))
         (key-down (lambda (e)
                     (if (not (eql (ffi:ref e "repeat") js:true))
                         (progn
                           (funcall update-movement (ffi:ref e "keyCode") 1)
                           (if (eql (ffi:ref e "keyCode") 32)
                               ((ffi:ref app "fire") #j"firstperson:jump"))))))
         (key-up (lambda (e)
                   (funcall update-movement (ffi:ref e "keyCode") 0)))

         (add-event-listeners (lambda (&rest _)
                                (#j:window:addEventListener #j"keydown" key-down t)
                                (#j:window:addEventListener #j"keyup" key-up t)))
         (remove-event-listeners (lambda (&rest _)
                                   (#j:window:removeEventListener #j"keydown" key-down t)
                                   (#j:window:removeEventListener #j"keyup" key-up t))))
    ((ffi:ref js:this "on") #j"enable" add-event-listeners)
    ((ffi:ref js:this "on") #j"disable" remove-event-listeners)

    (funcall add-event-listeners)))

(defparameter mouse-input (create-script "mouseinput"))

(defprotomethod initialize mouse-input (_)
  (let* ((app (ffi:ref js:this app))
         (canvas (ffi:ref app "graphicsDevice" "canvas"))
         (mouse-down (lambda (e)
                       (if (and (not (eql #j:document:pointerLockElement canvas))
                                (ffi:ref canvas "requestPointerLock"))
                           (progn
                             ((ffi:ref app "mouse" "enablePointerLock"))))))
         (mouse-move (lambda (e)
                       (if (eql #j:document:pointerLockElement #j:document:body)
                           (progn
                             (ffi:set (ffi:ref js:this "movementX") (or (ffi:ref e "movementX") (ffi:ref e "webkitMovementX") (ffi:ref e "mozMovementX") 0))
                             (ffi:set (ffi:ref js:this "movementY") (or (ffi:ref e "movementY") (ffi:ref e "webkitMovementY") (ffi:ref e "mozMovementY") 0))
                             ((ffi:ref app "fire") #j"firstperson:look" 
                                                   (- (* (ffi:ref js:this "movementX") 0.125))
                                                   (- (* (ffi:ref js:this "movementY") 0.125)))))))

         (add-event-listeners (lambda (&rest _)
                                (#j:window:addEventListener #j"mousedown" mouse-down js:false)
                                (#j:window:addEventListener #j"mousemove" mouse-move js:false)))
         (remove-event-listeners (lambda (&rest _)
                                   (#j:window:removeEventListener #j"mousedown" mouse-down js:false)
                                   (#j:window:removeEventListener #j"mousemove" mouse-move js:false))))
    ((ffi:ref js:this "on") #j"enable" add-event-listeners)
    ((ffi:ref js:this "on") #j"disable" remove-event-listeners)
      
    (funcall add-event-listeners)))

(defparameter reset (create-script "reset"))

(defprotomethod initialize reset (_)
  (let* ((app (ffi:ref js:this "app"))
         (rb (ffi:ref js:this "entity" "rigidbody"))
         (pos ((ffi:ref js:this "entity" "getPosition")))
         (pos-x (ffi:ref pos "x"))
         (pos-y (ffi:ref pos "y"))
         (pos-z (ffi:ref pos "z"))
         (on-reset (lambda (e &rest _)
                     ((ffi:ref rb "teleport") pos-x pos-y pos-z)
                     (js-setf (rb "linearVelocity") #j:pc:Vec3:ZERO
                              (rb "angularVelocity") #j:pc:Vec3:ZERO))))
    ((ffi:ref app "on") #j"firstperson:reset"
                        on-reset
                        js:this)))

(defprotomethod update reset (dt &rest _)
  (let ((app (ffi:ref js:this "app"))
        (pos (ffi:ref js:this "entity" "position")))
    (if (< (ffi:ref pos "y") -8)
        ((ffi:ref app "fire") #j"firstperson:reset"))))

