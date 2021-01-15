import liblo
import sys

# read all of stdin and put in one string
contents = "\n".join( sys.stdin.readlines() )
# send as a raw string
liblo.send(liblo.Address(7777), contents)

# in vim, we do this to send visual selection
#:w ! python3 send_to_max.py

# my remap. have to have mapped the leader key too!
# let mapleader=","
#:noremap <Leader>e :w !python3 send_to_max.py<Enter>   
