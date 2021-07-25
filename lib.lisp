(in-package :portal-plurality)

(progn
  (defun create-script (script-name)
    (js:pc.create-script script-name))

  (defmacro add-attribute (obj attr-name &rest attr-obj)
    `((ffi:ref ,obj "attributes" "add") ,attr-name (ffi:object ,@attr-obj))))