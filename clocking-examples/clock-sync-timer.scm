(define (start)
  (post "start")
  (clock-ticks 480 clock-cb)
)

(define (stop)
  (post "stop")
  (cancel-clock-ticks)
)

(define (clock-cb . args)
  (post "clock-cb")
  (out 0 'bang))


(post "clock-sync-timer.scm loaded")
