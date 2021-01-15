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



