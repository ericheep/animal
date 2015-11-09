// Behavior.ck
// animal behavior

public class Behavior {

    // static communication object
    Handshake h;

    int breathing, solenoid;

    fun void actuate(int velocity) {
        h.talk.note(solenoid, velocity);
    }

    fun void init(int s) {
        s => solenoid;
    }

    fun void beat() {
        actuate(127);
    }

    fun void heartbeat() {
        actuate(200);
        Math.random2(1900, 2100)::ms => now;
    }

    fun void breathe() {
        Math.random2(5, 10) => int distance;
        5 => int velocity;
        5::ms => dur speed;
        Math.random2(750, 1500)::ms => dur total;

        envelope(velocity, distance, speed, total);
    }

    fun void peck() {
        Math.random2(1, 4) => int distance;
        15 => int velocity;
        50::ms => dur speed;
        1000::ms => dur total;

        envelope(velocity, distance, speed, total);
    }

    fun void shimmer() {
        Math.random2(3, 4) => int distance;
        3 => int velocity;
        8::ms => dur speed;
        1000::ms => dur total;

        envelope(velocity, distance, speed, total);
    }

    // envelope
    fun void envelope(int velocity, int distance, dur speed, dur total) {

        (total/speed) $ int => int iterations;
        iterations/distance => int div;

        for (0 => int i; i < iterations/2; i++) {
            if (i % div == 0) {
                1::ms +=> speed;
            }
            actuate(velocity);
            speed => now;
        }
        for (iterations/2 => int i; i > 0; i--) {
            if (i % div == 0) {
                1::ms -=> speed;
            }
            actuate(velocity);
            speed => now;
        }
    }
}
