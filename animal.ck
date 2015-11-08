// turns receiving osc messages into serial messages
Hid hi;
HidMsg msg;

0 => int device;
if (!hi.openKeyboard(device)) me.exit();
<<< "Keyboard: " + hi.name() + " activated!", "">>>;


// serial setup
SerialIO serial;
SerialIO.list() @=> string list[];

int serial_port;

for (int i; i < list.cap(); i++) {
    if (list[i].find("usb") > 0) {
        i => serial_port;
        <<< "Connected to", list[i] >>>;
    }
}

// serial connecting
if (!serial.open(serial_port, SerialIO.B57600, SerialIO.BINARY)) {
    <<< "Unable to open serial device:", "\t", list[serial_port] >>>;
}
else {
    <<< list[serial_port], "assigned to port", serial_port, "" >>>;
}

// note function
fun void note(int num, int vel) {
    // this might work, not sure really
    //actuator[num] => num;
    // bitwise operations, allows note numbers 0-63 and note velocities 0-1023
    int bytes[3];
    255 => bytes[0];
    (num << 2) | (vel >> 8) => bytes[1];
    vel & 255 => bytes[2];
    serial.writeBytes(bytes);
}

2.0::second => now;

[0, 1] @=> int notes[];

while (true) {
    for (int i; i < notes.size(); i++) {
        note(notes[i], 127);
        // <<< i, notes[i] >>>;
        085::ms => now;
    }
}
