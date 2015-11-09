// Analyze.ck
// class that analyzes indivdual channels and returns
// information about them

public class Analyze extends Chubgraph {

    inlet => Gain g => OnePole p => blackhole;
    adc => g;

    3 => g.op;
    0.9999 => p.pole;

    fun float rms() {
        return p.last();
    }

}
