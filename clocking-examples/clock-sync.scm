
(define handle #f)
(define playing #f)

(define (start)
  (post "stop")
  ;(clock-ticks 480 clock-cb)
  (clock-cb)
)

(define (stop)
  (post "start")
  ;(cancel-clock-ticks)
  (set! playing #t)
  (cancel-delay handle)
)

(define (clock-cb . args)
  (if playing 
    (set! handle (delay-t 480 clock-cb)))
  (post "clock-cb")
  (out 0 'bang))


(post "clock-sync.scm loaded")
