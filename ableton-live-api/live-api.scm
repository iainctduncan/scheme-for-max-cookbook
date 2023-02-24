(post "live-api.scm")

; Scheme for Max Live-API interface
; by Iain Duncan, September 2021

; Note: this will only run in an s4m @thread low instance, it will refuse to do anything from high thread
; As all live.api objects defer anyway, this makes no difference.
; If you want to call it from an s4m @thread high instance, make a low instance and send it messages,
; which get automatically defered.
;
; This code assumes the following patchingm where {} indicates scripting name:
; |live.path {live-path}| -> |route id| -> |prepend live-api 'id| -> |s4m @thread low|
; |id $1 {live-object-id}| -> |live.object {live-object}| -> |route value| -> |prepend live-api 'value| -> |s4m @thread low|

; Sample calls:
; find and send a message:
;   (live-api 'send-path '(live_set tracks 0 clips_slots 0 clip) '(call fire))
; - optional thispatcher scripting to do the max object dependency creation for us  



; a sample high level api object that user might extend
; sample call: (live 'get-track-volume 0)
; you would add your high level methods here
(define (live . args)

  ; sample high level methods one might make
  (define (fire-clip track slot)
    (live-api 'send-path `(live_set tracks ,track clip_slots ,slot clip) '(call fire)))

  (define (stop-clip track slot)
    (live-api 'send-path `(live_set tracks ,track clip_slots ,slot clip) '(call stop)))

  (define (get-track-volume track)
    (live-api 'send-path `(live_set tracks ,track mixer_device volume) `(get value)))

  (define (set-track-volume track volume)
    (live-api 'send-path `(live_set tracks ,track mixer_device volume) `(set value ,volume)))

  ; dispatcher
  (let ((msg (car args))
        (args (cdr args)))
    (apply (eval msg) args))
)
      

; the low-level api, you should not need to touch this
(define live-api
  (let ((obj-id #f)   ; object id of last path request
        (value #f)    ; value received for successful value requests
        (debug #f))   ; set to true for verbose log messages
 
    ; the id callback, called from the response from the live.path obj
    ; updates internal (last object) id and sends id message to the live.object
    (define (update-id id)
      (log-debug "live-api.update-id" id)
      (set! obj-id id)
      (send 'live-object-id 'int obj-id))

    ; the value callback, called from the response from the live.object obj
    ; updates internal (last object) value so caller can return value
    (define (update-value value-in)
      (log-debug "live-api.update-value" value-in)
      (set! value value-in))

    ; method to find an object from a live path
    ; results in live.path object calling back with the id callback
    (define (find-path path)
      (log-debug "(live-api.find" path ")")
      (set! obj-id #f)
      (apply send (cons 'live-path (cons 'path path))))

    (define (send-object msg-list)
      (log-debug "live-api.send-object" msg-list )
      (set! value #f)
      (apply send (cons 'live-object msg-list))
      ; if the above resulted in an update to value, return it, else null
      (if value value '()))

    (define (send-path path msg)
      (log-debug "live-api.send-path" path msg)
      (find-path path)
      (send-object msg))

    (define (log-debug . args)
      (if debug (apply post args) '()))

    ; dispatcher
    (lambda (msg . args)
      (if (isr?)
        (post "Error: live-api requires s4m @thread low")
        (case msg
          ('id        (update-id (args 0)))     
          ('value     (update-value (args 0)))     
          ('path      (find-path (args 0)))
          ('object    (send-object (args 0)))
          ('send-path (send-path (args 0) (args 1)))
          (else '()))))
))    

  




; sample max patcher code of the object dependencies
;{
;	"boxes" : [ 		{
;			"box" : 			{
;				"maxclass" : "newobj",
;				"text" : "route id",
;				"id" : "obj-36",
;				"outlettype" : [ "", "" ],
;				"patching_rect" : [ 12.999999701976776, 46.533334314823151, 49.0, 22.0 ],
;				"numinlets" : 2,
;				"numoutlets" : 2
;			}
;
;		}
;, 		{
;			"box" : 			{
;				"maxclass" : "message",
;				"varname" : "live-object-id",
;				"text" : "id $1",
;				"id" : "obj-22",
;				"outlettype" : [ "" ],
;				"patching_rect" : [ 114.999999701976776, 19.800000786781311, 35.0, 22.0 ],
;				"numinlets" : 2,
;				"numoutlets" : 1
;			}
;
;		}
;, 		{
;			"box" : 			{
;				"maxclass" : "newobj",
;				"varname" : "live-object",
;				"text" : "live.object",
;				"id" : "obj-10",
;				"outlettype" : [ "" ],
;				"patching_rect" : [ 71.999999701976776, 46.533334314823151, 62.0, 22.0 ],
;				"numinlets" : 2,
;				"numoutlets" : 1,
;				"saved_object_attributes" : 				{
;					"_persistence" : 1
;				}
;
;			}
;
;		}
;, 		{
;			"box" : 			{
;				"maxclass" : "newobj",
;				"text" : "prepend live-api 'id",
;				"id" : "obj-24",
;				"outlettype" : [ "" ],
;				"patching_rect" : [ 12.999999701976776, 72.00000137090683, 109.0, 22.0 ],
;				"numinlets" : 1,
;				"numoutlets" : 1
;			}
;
;		}
;, 		{
;			"box" : 			{
;				"maxclass" : "newobj",
;				"varname" : "live-path",
;				"text" : "live.path",
;				"id" : "obj-20",
;				"outlettype" : [ "", "", "" ],
;				"patching_rect" : [ 12.999999701976776, 19.800000786781311, 53.0, 22.0 ],
;				"numinlets" : 1,
;				"numoutlets" : 3
;			}
;
;		}
;, 		{
;			"box" : 			{
;				"maxclass" : "newobj",
;				"text" : "s4m live-api.scm @thread l",
;				"id" : "obj-37",
;				"outlettype" : [ "" ],
;				"patching_rect" : [ 12.999999701976776, 98.999999463558197, 153.0, 22.0 ],
;				"numinlets" : 1,
;				"numoutlets" : 1,
;				"saved_object_attributes" : 				{
;					"ins" : 1,
;					"log-null" : 0,
;					"outs" : 1,
;					"thread" : 108
;				}
;
;			}
;
;		}
; ],
;	"lines" : [ 		{
;			"patchline" : 			{
;				"source" : [ "obj-22", 0 ],
;				"destination" : [ "obj-10", 1 ]
;			}
;
;		}
;, 		{
;			"patchline" : 			{
;				"source" : [ "obj-20", 0 ],
;				"destination" : [ "obj-36", 0 ]
;			}
;
;		}
;, 		{
;			"patchline" : 			{
;				"source" : [ "obj-36", 0 ],
;				"destination" : [ "obj-24", 0 ]
;			}
;
;		}
;, 		{
;			"patchline" : 			{
;				"source" : [ "obj-24", 0 ],
;				"destination" : [ "obj-37", 0 ]
;			}
;
;		}
; ],
;	"appversion" : 	{
;		"major" : 8,
;		"minor" : 1,
;		"revision" : 11,
;		"architecture" : "x64",
;		"modernui" : 1
;	}
;,
;	"classnamespace" : "box"
;}
;
