;; Thread Macro
(define-macro (~> object . functions)
  (let ((hole :$))
    (define (plug-hole expression cork)
      (let iter ((expression expression))
        (cond
         ((null? expression) expression)
         ((eq? hole (car expression)) (cons cork
                                            (iter (cdr expression))))
         (else
          (cons (car expression) (iter (cdr expression)))))))
    (let thread-transform-loop
        ((needle object)
         (fns functions))
      (if (null? fns)
          needle
          (append (thread-transform-loop (plug-hole (car fns) needle)
                                         (cdr fns)))))))



;; Unit Tests
(define (test)
  (expect '~>-works
          =
          (~> '((not-my-list . (666 999))
                (my-list . (5 3 2)))
              (assoc 'my-list :$)
              (cdr :$)
              (car :$))
          5)
  )
