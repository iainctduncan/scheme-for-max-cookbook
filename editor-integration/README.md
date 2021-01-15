# Scheme For Max Cookbook - Editor Integration

This recipe demonstrates an effective workflow for sending code to Scheme For Max from your editor.
Specifically, this includes mapper functions for Vim, GVim, or MVim, but adapting to other
editors should be simple.

## Overview
In a nutshell, the way it works is:
* The editor sends a block of text as STDIN to a shell command, using vim key mappings
* The shell command runs a Python script that reads all lines available from STDIN and sends 
  them out over the local network as a single OSC message with a string payload
* Max receives the OSC message using the **udpreceive** object, prepares a message
  of 'eval-string "(all the code from the editor"', and sends it to the s4m object


# Python code
I used the pyliblo package for sending OSC data, which required me to download and install 
both liblo and pyliblo. You could use any OSC library, but pyliblo is nice because it works
on both python 2.X and 3.X, and has nice online examples.

The Python script is very simple. I've saved it as 'send_to_max.py' on my system.

~~~
  import liblo
  import sys

  # set port, needs to match arg to udpreceive in Max
  port = 7777
  # read all of stdin and put in one string
  contents = "\n".join( sys.stdin.readlines() )
  # send as a raw string
  liblo.send(liblo.Address(port), contents)
  # you could also preface the raw contents to make various osc messages  
~~~

# Max code

In max, we make a udpreceive object, set to match the port we used in the Python 
script. We hook that up to to a 'prepend eval-string' object, and then into the s4m object.
Keep in mind that if you have many patchers going, all udpreceive objects will get the message
so you might want some routing or gates in place.

# Testing

We can test whether this is working at the shell by redirecting STDIN to our Python script
and seeing if it goes to Max.

    $ echo "(post :hello-world)" | python3 send_to_max.py

We should see the message come in to Max.

# Adding to Vim

In vim, mapping keys to do what we want is pretty simple. Here's what I have in my .vimrc

~~~  
  let mapleader = ","
  nnoremap <leader>e va):w ! python3 /usr/local/bin/send_to_max.py<Enter><Enter>
  vnoremap <leader>e :w ! python3 /usr/local/bin/send_to_max.py<Enter><Enter>

  nmap <D-e> <Esc>va):w ! python3 /usr/local/bin/send_to_max.py<Enter><Enter>va)dgg^i
  imap <D-e> <Esc>va):w ! python3 /usr/local/bin/send_to_max.py<Enter><Enter>va)dgg^i
~~~

I set my leader key to the comma character, and the mappings are doing the following.

1) If in normal mode, pressing ',e' does a visual select of the currently enclosed 
parenthetical expression, followed by the ex command to send selection to the Python 
script as STDIN.

2) If in visual mode, pressing ',e' sends the current visual selection, as above

3) If in normal mode, Option-E (I'm on a Mac) selects the currently enclosed paranthetical
expression, sends it to python, then deletes it and puts me in insert mode back at
the beginning of the line. This is meant to act like I'm at a line-input in a REPL

4) If in insert mode, do the same thing as 3.


# Other editors
All we need is keystrokes that send the text we have highlighted out as STDIN to the
Python script. If you get this going for other editors, let me know and we can update 
this recipe!


# Issues:
At the moment (2021-01-15), you can only send one paranthetical expression. If you want
so send many, you'll need to wrap them in a begin statement:

~~~
  (begin    
    (first sexp to eval)
    (second sexp to eval)
  ); end of begin
~~~

I intent to fix Scheme for Max so that eval-string does this automatically for us,
and I will update this tutorial once that is done.
