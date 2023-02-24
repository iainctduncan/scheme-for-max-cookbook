(post "apply-fade.scm")

; fill with one period of a sine of given amp, frq, samplerate
(define (fill-sine buffer amp frq sr)
  "fill a named buffer with a sine"
  (dotimes (i (buffer-size buffer))
    (bufs buffer i 
      (* amp 
        (sin (* i (/ (* 2.0 pi) (/ sr frq))))))))

(define (apply-fade-in buffer smps)
  "apply a linear fade in over smps samples to named buffer"
  (dotimes (i smps)
    (let* ((env-val (* i (/ 1.0 smps)))
           (prv-smp (bufr buffer i))
           (out-smp (* env-val prv-smp)))
      (bufs buffer i out-smp))))


