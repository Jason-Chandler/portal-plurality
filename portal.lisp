(in-package :portal-plurality)

(defparameter *active-portals* '())

(defun get-end-vec (start-portal)
  (getf *active-portals* start-portal))

(defun teleport-to-alt (ent portal-name &rest _)
  (let* ((vec (get-end-vec portal-name))
         (x (ffi:ref vec x))
         (y (ffi:ref vec y))
         (z (ffi:ref vec z)))
    (js:console.log ent)
    (js:console.log _)
    (teleport ent :x x :y y :z z)))

(defun add-alignment (end-vec alignment)
  (let ((x (ffi:ref end-vec x))
        (y (ffi:ref end-vec y))
        (z (ffi:ref end-vec z)))
    (case alignment
      ("x" (ffi:new (ffi:ref "pc.Vec3") (+ x 5) y z))
      ("y" (ffi:new (ffi:ref "pc.Vec3") x (+ y 5) z))
      ("z" (ffi:new (ffi:ref "pc.Vec3") x y (+ z 5)))
      (t (error "Alignment must be x, y, or z")))))

(defun scale-by-alignment (ring alignment)
  (ffi:set (ffi:ref ring local-scale) (case alignment 
                                  ("x" (vec3 :x 0.1 :y 5 :z 1))
                                  ("y" (vec3 :x 5 :y 0.1 :z 1))
                                  ("z" (vec3 :x 1 :y 5 :z 0.1))
                                  (t (error "Alignment must be x, y, or z")))))

(defun make-ring (start-vec end-vec alignment)
  (let* ((ring-name (gensym))
         (ring (ffi:new (ffi:ref "pc.Entity") #j(string ring-name)))
         (end-vec-final (add-alignment end-vec alignment)))
    ((ffi:ref ring add-component) #j"model")
    (ffi:set (ffi:ref ring model type) #j"sphere")
    ((ffi:ref ring add-component) #j"collision")
    (scale-by-alignment ring alignment)
    ((ffi:ref ring collision on) #j"triggerenter" (lambda (ent &rest _) (teleport-to-alt ent ring-name _)) ring)
    ((ffi:ref js:pc app root add-child) ring)
    (setf *active-portals* (cons ring-name (cons end-vec-final *active-portals*)))))

(defun make-portal (start-vec end-vec alignment &key two-way)
  (make-ring start-vec end-vec alignment)
  (if two-way
      (make-ring end-vec start-vec alignment)))

(make-portal (vec3 :x 0 :y 10 :z 5) (vec3 :x 5 :y 50 :z 0) "x" :two-way nil)

(js:console.log (getf *active-portals* "G3"))

(add-child (ffi:new (ffi:ref "pc.Entity")))

(js:console.log ((ffi:ref js:pc app root add-child) (ffi:new (ffi:ref "pc.Entity"))))