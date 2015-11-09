// tester.ck
// quick script for finding good actuator values

adc => Gain g => dac;

// for assigning values from the command line
50 => int speed;
64 => int velocity;

for (int i; i < me.args(); i++) {
    if (i == 0) {
        Std.atoi(me.arg(i)) => speed;
    }
    if (i == 1) {
        Std.atoi(me.arg(i)) => velocity;
    }
}



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
    // bitwise operations, allows note numbers 0-63 and note velocities 0-1023
    int bytes[3];
    255 => bytes[0];
    (num << 2) | (vel >> 8) => bytes[1];
    vel & 255 => bytes[2];
    serial.writeBytes(bytes);
}

2.0::second => now;

<<< " ", "" >>>;
<<< "Control speed with 'j' 'k', control velocity with 'd' 'f'", "" >>>;
<<< " ", "" >>>;
<<< "Speed:", speed, "ms | Velocity", velocity >>>;

[0, 1] @=> int notes[];

fun void input() {
    while (true) {
        // wait on HidIn as event
        hi => now;

        // messages received
        while (hi.recv(msg)) {
            if (msg.isButtonDown()) {
                if (msg.ascii == 74 && speed < 100) {
                    speed++;
                    <<< "Speed:", speed, "ms | Velocity", velocity >>>;
                }
                if (msg.ascii == 75 && speed > 1) {
                    speed--;
                    <<< "Speed:", speed, "ms | Velocity", velocity >>>;
                }
                if (msg.ascii == 70 && velocity < 127) {
                    velocity++;
                    <<< "Speed:", speed, "ms | Velocity", velocity >>>;
                }
                if (msg.ascii == 68 && velocity > 1) {
                    velocity--;
                    <<< "Speed:", speed, "ms | Velocity", velocity >>>;
                }
            }
        }
    }
}


spork ~ input();

// plays both solenoids at the same time
// with the given values
while (true) {
    for (int i; i < notes.size(); i++) {
        note(notes[i], velocity);
    }
    speed::ms => now;
}
