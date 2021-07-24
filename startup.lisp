(progn (ql:quickload :trivial-ws)
       (load #P"/home/jason/.roswell/lisp/quicklisp/local-projects/lem-valtan/remote-eval")
       (load #P"/home/jason/.roswell/lisp/quicklisp/local-projects/lem-valtan/valtan-mode")
       (load #P"/home/jason/.roswell/lisp/quicklisp/local-projects/lem-valtan/main"))
(lem-valtan/main:start #P"/home/jason/.roswell/lisp/quicklisp/local-projects/portal-plurality/portal-plurality.system")

(js:alert #j"test")
