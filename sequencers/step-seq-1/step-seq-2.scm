;*******************************************************************************
;; A very simple midi step sequencer for Scheme for Max
;; this is mean to be a simple example and thus includes no protection
;; against bad data (checking for valid midi ranges, etc)
;;
;; This code could be smaller if only numerical lookup was used, but we are
;; using keyword args and hashtables for readability

;*******************************************************************************
;; state vars. In production you might put these in a different file so as not
;; to clobber them when you reload the file

;; data tracks, for simplicty we are making a one bar sequencer of 4 tracks
(define data (vector 
  (make-vector 16 0) 
  (make-vector 16 120)  ;; initialize dur to a value of one 16th at 480pq
  (make-vector 16 0) 
  (make-vector 16 0)))

;; hash-table of sub-vector index for a given param
(define param-track (hash-table   
    :on     0      ;; on button for the step
    :dur    1      ;; duration in max clock ticks (480 ppq)
    :note   2      ;; amp, 0-127
    :vel    3      ;; midi note num  
))

;; internal var for the step we are on
(define curr-step 0)

;*******************************************************************************
;* UI functions to enable us to update the sequence data
(define (seq-reset)
  (post "reseting step to 0")
  (set! curr-step 0))

;; update a specific track, ie. (set-data {step} :on {value})
(define (set-track-data param step value)
  (set! ((trk-data :param) step) value)) 

;; update all values for a step, params is '({on} {dur} {note} {vel})
;; ie (set-data 4 1 480 64 128)
(define (set-data step params) 
  (set! ((track-data :on) step) (params 0))
  (set! ((track-data :dur) (
    
;; a function to take in a list of: step, active, dur, note, vel and set the
;; data accordingly


;*******************************************************************************
;; Engine functions for the sequencer

;; increment the step-counter or rollover to 0
(define (inc-step)
  (if (== curr-step 15)
    (set! curr-step 0)
    (set! curr-step (+ 1 curr-step))))  

;; return a hash (dict) of step data: active, dur, vel, note
(define (get-step-data step)
  (hash-table 
    :on   ((trk-data :on)   step) 
    :dur  ((trk-data :dur)  step) 
    :note ((trk-data :note) step) 
    :vel  ((trk-data :vel)  step))) 

;; play a note: output a list of values for duration, pitch, amp, suitable
;; for sending to a midi out patcher
(define (play-note step)
  (post "play note, step: ", step)
  (let ((step-data (get-step-data step)))
    ;; if step is active, output a list of (dur, note, vel)
    (if (> 0 (step-data :on))
      (out 0 (list (step-data :dur) (step-data :note) (step-data :vel)))))) 

;; callback to trigger runing a step, could be hooked up to a metro, etc 
(define (tick)
  (post "tick!")
  (inc-step)
  (play-note curr-step))



