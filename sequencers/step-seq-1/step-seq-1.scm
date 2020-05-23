;*******************************************************************************
;; The simplest possible step sequencer in Scheme for Max
;; Has 8 steps of one value

;*******************************************************************************
;; State vars. 
;; You might put these in a different file so as not to clobber them on reload

;; step data: an 8 point vector initialized to zero
(define data (make-vector 8 0))

;; internal var for the step we are on
(define curr-step 0)

;*******************************************************************************
;; Engine 

;; increment the step-counter or rollover to 0
(define (inc-step)
  (if (= curr-step 7)
    (set! curr-step 0)
    (set! curr-step (+ 1 curr-step))))  

;; a callback to trigger runing a step, triggered by a bang
;; this should be triggered from a high-priority event (metro, phasor, etc)
(define (tick)
  ;(post "tick: curr-step: " curr-step)
  (out 0 (data curr-step))
  (inc-step))

;*******************************************************************************
;* UI 

;; reset step to 0
(define (rewind)
  (set! curr-step 0))

;; update a data point, will receive max messages: update {int step} {int value}
(define (update step value)
  (set! (data step) value))



