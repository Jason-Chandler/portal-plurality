(in-package :portal-plurality)

(progn
  (defun create-script (script-name)
    (js:pc.create-script script-name))

  (defmacro add-attribute (obj attr-name &rest attr-obj)
    `((ffi:ref ,obj "attributes" "add") ,attr-name (ffi:object ,@attr-obj)))

  (defmacro defprotomethod (slot-name proto lambda-list &body proto-fn)
    `(ffi:set (ffi:ref ,proto "prototype" ,slot-name)
              (lambda (,@lambda-list) ,@proto-fn)))

  (defmacro new (obj-type &rest args)
    `(let ((this (ffi:object)))
       (if (null (list ,@args))
           (progn 
             ((ffi:ref js:pc ,obj-type "prototype" "constructor" "call") this)
             this)
           (progn 
             ((ffi:ref js:pc ,obj-type "prototype" "constructor" "call") this ,@args)
             this))))


  (defun vec3 (&key (x 0) (y 0) (z 0))
    (new "Vec3" x y z))

  (defun add-scripts (ent script-list)
    (loop for script in script-list
          do ((ffi:ref ent "script" "create") #jscript)))

  (defun remove-scripts (ent script-list)
    (loop for script in script-list
          do ((ffi:ref ent "script" "destroy") #jscript)))

  (defun add-component (ent comp-type)
    ((ffi:ref ent "addComponent") #jcomp-type))

  (defun find-by-name (name)
    (js:pc.app.root.find-by-name #jname)))