
(define handle #f)
(define playing #f)

(define (start)
  (post "start")
  (set! playing #t)
  (clock-cb)
)

(define (stop)
  (post "stop")
  (set! playing #f)
  (cancel-delay handle)
)

(define (clock-cb)
  (if playing 
    (set! handle (delay-t 480 clock-cb)))
  (post "clock-cb")
  (out 0 'bang)
)


(post "clock-sync-delay.scm loaded")
