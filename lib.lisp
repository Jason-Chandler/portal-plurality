(in-package :portal-plurality)

(defun create-script (script-name)
  (js:pc.create-script #jscript-name))

(defmacro add-attribute (obj attr-name &rest attr-obj)
  `((ffi:ref ,obj "attributes" "add") #j,attr-name (ffi:object ,@attr-obj)))

(defun symb->camel-case (sym)
  `(compiler::kebab-to-lower-camel-case (string ',sym)))

(defmacro defprotomethod (slot-name proto lambda-list &body proto-fn)
  `(ffi:set (ffi:ref ,proto "prototype" ,(compiler::kebab-to-lower-camel-case 
                                          (string slot-name)))
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

(defmacro js-setf (&rest forms)
  (flet ((set-pair (pair)
           (if (listp (car pair))
               `(ffi:set (ffi:ref ,@(car pair)) ,(cadr pair))
               `(setf ,(car pair) ,(cadr pair)))))
    `(progn ,@(mapcar #'set-pair (loop for (key value) on forms by #'cddr
                                     collect (list key value))))))q
   
(defun add-scripts (ent script-list)
  (loop for script in script-list
        do ((ffi:ref ent "script" "create") #jscript)))

(defun remove-scripts (ent script-list)
  (loop for script in script-list
        do ((ffi:ref ent "script" "destroy") #jscript)))

(defun add-component (ent comp-type)
  ((ffi:ref ent "addComponent") #jcomp-type))

(defun find-by-name (name)
  (js:pc.app.root.find-by-name #jname))