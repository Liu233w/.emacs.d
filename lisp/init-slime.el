;; I use sbcl, `C-h v slime-read-interactive-args RET` for details
;; you need install the program sbcl, of course
;;(setq inferior-lisp-program "sbcl")

(cond
 (*win64* (setq inferior-lisp-program "wx86cl64"))
 (*cygwin* (setq inferior-lisp-program "clisp"))
 (*linux* (setq inferior-lisp-program "sbcl"))
 (t (setq inferior-lisp-program "sbcl")))

(eval-after-load 'slime
  '(progn
     (add-to-list 'load-path (concat (directory-of-library "slime") "/contrib"))
     (setq slime-contribs '(slime-fancy))
     (setq slime-protocol-version 'ignore)
     (setq slime-net-coding-system 'utf-8-unix)
     (setq slime-complete-symbol*-fancy t)
     ))

(provide 'init-slime)
