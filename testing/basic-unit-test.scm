;; For those of us who like unit testing, here is an exceedingly simple test suite.
;;
;;  Right now this is just the simplest thing that could work.  

(define (test)
  (expect '=-checks-for-numeric-equality
          =
          2
          2)
  (expect 'equal?-checks-for-list-equality
          equal?
          '(a b c)
          '(a b c)))

(define (expect name condition a b)
  (let ((result (apply condition (list a b))))
    (if result
        (post name)
        (error 'test-failure
               (with-output-to-string
                 (lambda ()
                   (display "failure: ")
                   (display name)
                   (newline)
                   (display "Comparison: ")
                   (display (object->string condition))
                   (newline)
                   (display (object->string a))
                   (newline)
                   (display (object->string b))))))))
