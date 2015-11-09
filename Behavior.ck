// Behavior.ck
// animal behavior

public class Behavior {

    // static communication object
    Handshake h;

    int breathing, solenoid;

    fun void hit(int vel) {
        h.talk.note(solenoid, vel);
    }

    fun void init(int s) {
        s => solenoid;
    }

    fun void beat() {
        hit(127);
    }

    fun void breathe(int b) {
        if (b) {
            1 => breathing;
        }
        else {
            0 => breathing;
        }
        for (int i ; i < 100; i++) {
            hit(2);
            1::ms => now;
        }
    }
}
