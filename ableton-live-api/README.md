# Using the Ableton Live API from Scheme For Max

This recipe shows you how to make a live-api interface in s4m.
So far it covers using live.path and live.object, so it can be used for triggering
message based actions and querying API settings. 
Live.observer and live.remote will be covered in future examples.

Notes:
There is some max patching that this depends on. You need to set that up, and run 'scan' for it
to work so that the objects with scripting names can be found. The plumbing is in the
"live-api" abstraction in the sample patch. 
 
This only works in the low priority thread - this is a limitation of Max4Live, not Scheme for Max,
and is the same as any use of the Live API as live.object implicitly defers to the low thread.
Rather than have it misbehave, I have it check the thread and refuse to do anything if in the high-thread.
To trigger api calls from a high thread, you should make a second s4m object in the  low thread 
and send it messages to tell it to make API calls. These will automatically be defered 
and will run on the next low priority thread pass.

The **live-api** object is the low-level api interface. You would normally leave this alone.
If you want to trace it's execution, set the **debug** attribute to #true for verbose logging.

The **live** object is an example of an object you might make to put your high-level functions
in that call the API.

This has been tested with Scheme for Max 0.2, Live 11, and Max 8. 
