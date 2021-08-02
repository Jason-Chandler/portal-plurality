(in-package :portal-plurality)

(defparameter *active-portals* '())

(defun get-end-vec (start-portal)
  (getf *active-portals* start-portal))

(defun teleport-to-alt (ent portal-name &rest _)
  (let* ((vec (get-end-vec portal-name))
         (x (ffi:ref vec x))
         (y (ffi:ref vec y))
         (z (ffi:ref vec z)))
    (teleport ent :x x :y y :z z)))

(defun scale-by-alignment (ring alignment)
  (ffi:set (ffi:ref ring local-scale) (case alignment 
                                        ('x (vec3 :x 0.1 :y 5 :z 2.5))
                                        ('y (vec3 :x 5 :y 0.1 :z 2.5))
                                        ('z (vec3 :x 2.5 :y 5 :z 0.1))
                                        (t (error "Alignment must be x, y, or z")))))

(defun extents-by-alignment (ring-coll alignment)
  (ffi:set (ffi:ref ring-coll half-extents) (case alignment 
                                        ('x (vec3 :x 0.05 :y 2.5 :z 1.25))
                                        ('y (vec3 :x 2.5 :y 0.05 :z 1.25))
                                        ('z (vec3 :x 1.25 :y 2.5 :z 0.05))
                                        (t (error "Alignment must be x, y, or z")))))

(defun make-ring (start-vec end-vec alignment)
  (let* ((ring-name (gensym))
         (ring (ffi:new (ffi:ref "pc.Entity") #j(string ring-name)))
         (end-vec-final end-vec))
    (load-glb ring "./files/assets/portorb.glb" nil)
    ((ffi:ref ring add-component) #j"collision")
    (ffi:set (ffi:ref ring collision type) #j"box")
    (scale-by-alignment ring alignment)
    (extents-by-alignment (ffi:ref ring collision) alignment)
    ((ffi:ref ring collision on) #j"triggerenter" (lambda (ent &rest _) (teleport-to-alt ent ring-name _)) ring)
    ((ffi:ref js:pc app root add-child) ring)
    ((ffi:ref ring translate) start-vec)
    (make-light ring
                (ffi:ref start-vec x)
                (ffi:ref start-vec y)
                (ffi:ref start-vec z)
                "point"
                :r (* (+ 50.0 (random 206.0)) 0.003921568627451)
                :g (* (+ 50.0 (random 206.0)) 0.003921568627451)
                :b (* (+ 50.0 (random 206.0)) 0.003921568627451))
    (setf *active-portals* (cons ring-name (cons end-vec-final *active-portals*)))))

(defun make-portal (start-vec end-vec alignment &key two-way)
  (make-ring start-vec end-vec alignment)
  (if two-way
      (make-ring end-vec start-vec alignment)))

