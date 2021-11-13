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
  (make-vector 16 0)    ;; on-vector
  (make-vector 16 120)  ;; dur-vector
  (make-vector 16 0)    ;; pitch(note)-vector
  (make-vector 16 0)))  ;; vel-vector

;; hash-table of sub-vector index for a given parameter
(define parameters (hash-table   
    :on     0      ;; on button for the step
    :dur    1      ;; duration in max clock ticks (1/4 note = 480 ppq)
    :note   2      ;; midi note number
    :vel    3  ))  ;; note velocity

;; return parameter data by keywords defined in parameters hash-table
;;; e.g. (track-data :note)
(define (track-data param)
  (data (parameters param)))

;; internal var for the step we are on
(define curr-step 0)

;*******************************************************************************
;* UI functions to enable us to update the sequence data

(define (seq-reset)
  (post "reseting step to 0")
  (set! curr-step 0))

;; update a specific track
;; (set-data {step} :on {value})
(define (set-track-data step param value)
  (set! ((track-data param) step) value))

;; update all values for a step.
;; note-data-list is '({on} {dur} {note} {vel})
;;; e.g. (set-data 2 '(1 120 60 100)) 
;;; sets play(1) C3(60) 16th note(120) at 100 velocity on step #2.
(define (set-data step param-list)
  (set! ((track-data :on)   step) (param-list 0))
  (set! ((track-data :dur)  step) (param-list 1))
  (set! ((track-data :note) step) (param-list 2))
  (set! ((track-data :vel)  step) (param-list 3)) )

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
    :on   ((track-data :on)   step) 
    :dur  ((track-data :dur)  step) 
    :note ((track-data :note) step) 
    :vel  ((track-data :vel)  step))) 

;; play a note: output a list of values for duration, pitch, amp, suitable
;; for sending to a midi out patcher
(define (play-note step)
  (post "play note, step: " step)
  (let ((step-data (get-step-data step)))
    (if (= 1 (step-data :on))
        (out 0 (list (step-data :dur)
                     (step-data :note)
                     (step-data :vel) ))
        (post "step is off") )))

;; callback to trigger runing a step, could be hooked up to a metro, etc 
(define (tick)
  (post "tick!")
  (inc-step)
  (play-note curr-step))
