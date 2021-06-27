
(define transpose 12)
(define tempo 120)
(define playing #f)

(define (f-int v)
  (out 0 (+ transpose v))) 

(define (play-note)
  (out 0 (+ transpose 60))
  (if playing   
    (delay (/ (* (/ 60.0 tempo) 1000) 2) play-note)))

(define (start)
  (if (not playing)
    (begin 
      (set! playing #t)   
      (play-note))))

(define (stop)
  (set! playing #f))
