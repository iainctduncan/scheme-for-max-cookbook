
// simple script to receive a bang and output a note message

// receive an int, output it offset by 12
function msg_int(v){
	//post("received int " + v + "\n");
	outval = v + 12;
    outlet(0, outval);
}


