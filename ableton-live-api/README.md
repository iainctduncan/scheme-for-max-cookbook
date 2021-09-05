# Using the Ableton Live API from Scheme For Max

This recipe shows you how to make a live-api interface in s4m.
So far it covers using live.path and live.object, so it can be used for triggering
message based actions and querying API settings. 
Live.observer and live.remote will be covered in future examples.

Notes:
There is some max patching that this depends on. You need to set that up, and run 'scan' for it
to work so that the objects with scripting names can be found. The plumbing is in the
"live-api" abstraction in the sample patch. 
 
This only works in the low priority thread - this is a limitation of Max4Live, not Scheme for Max.
Rather than have it misbehave, I have it check the thread and refuse to do anything if in the high-thread.
To use from a high thread, make a low thread s4m object and send it messages for API calls. These
will automatically be defered and will run on the next low priority thread pass.


