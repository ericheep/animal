// serial
Handshake h;
0.5::second => now;
h.talk.init();

// number of actuators
2 => int NUM_ACTUATORS;

// analyze
Analyze ana[NUM_ACTUATORS];

// behavior
Actuate act[NUM_ACTUATORS];

// sound chain
Gain g[NUM_ACTUATORS];
Dyno d[NUM_ACTUATORS];

for (int i; i < NUM_ACTUATORS; i++) {
    ana[i].init(i);
    act[i].init(i);
    // analyze
    adc.chan(i) => ana[i];
    // left/right pan
    adc.chan(i) => g[i] => d[i] => dac.chan(i);
    // limiter
    d[i].limit();
}

// vars
int heartpumping_ready[NUM_ACTUATORS];
dur die[NUM_ACTUATORS];
float decibel_filter[NUM_ACTUATORS][30];
float decibel_average[NUM_ACTUATORS];

now => time start;

// for debug printing timestamps
fun int stopwatch() {
    return ((now - start)/second) $ int;
}

// behavior functions
fun void bloodFlow(int idx) {
    <<< "~ bloodflow -", idx, "-", stopwatch() >>>;
    for (11.5 => float i; i > 6.0; i - 0.1 => i) {
        act[idx].straight(5, i::ms, Math.random2(500, 1250)::ms);
    }
}

fun void heartStart(int idx) {
    <<< "~ heartstart -", idx, "-", stopwatch() >>>;

    int ctr;
    int intensity;

    // big hit
    act[idx].hit(127);

    Math.random2(190, 300)::ms => now;

    while (intensity < 8) {
        Math.random2(300, 500) => int iterations;
        5 + intensity => int velocity;

        if (intensity < 5) {
            act[idx].straight(5, Math.random2f(6.0, 11.5)::ms, iterations * (8 - intensity)::ms);
        }
        else {
            for (iterations/2 => int i; i > 0; i--) {
                act[idx].hit(velocity);
                (i + 5)::ms => now;
            }
        }

        act[idx].hit(127);
        Math.random2(400, 500)::ms => now;

        if (intensity < 5) {
            act[idx].straight(5, Math.random2f(6.0, 11.5)::ms, iterations * (8 - intensity)::ms);
        }
        else if (intensity < 7) {
            for (1 => int i; i < iterations/2; i++) {
                act[idx].hit(velocity);
                (i + 5)::ms => now;
            }
        }

        intensity++;
    }

    // lets the next function know when it's ready to continue
    1 => heartpumping_ready[idx];
}

// beating strong
fun void heartPumping(int idx) {
    while (heartpumping_ready[0] == 0 || heartpumping_ready[1] == 0) {
        1::samp => now;
    }

    <<< "~ heartpumping -", idx, "-", stopwatch() >>>;
    for (int k; k < 12; k++) {
        for (int i; i < 100 - Math.random2(8, 16); i++) {
            for (int j; j < 2; j++) {
                if (j == idx) {
                    act[idx].hit(50);
                }
                (40 + k)::ms => now;
            }
        }
        for (int i; i < Math.random2(2, 6); i++) {
            for (int j; j < 2; j++) {
                if (j == idx) {
                    act[idx].hit(50);
                }
                (45 + k)::ms => now;
            }
        }
    }
}

// heart trouble
fun void cardiacArrest(int idx) {
    spork ~ decibelFilter(idx);

    <<< "~ cardiacArrest -", idx, "-", stopwatch() >>>;
    for (int i ;i < 50; i++) {
        for (int j; j < 2; j++) {
            if (j == idx) {
                act[idx].hit(50);
            }
            50::ms + i::ms => now;
        }
    }
    for (50 => int i ;i > 0; i--) {
        for (int j; j < 2; j++) {
            if (j == idx) {
                act[idx].hit(50);
            }
            50::ms + i::ms => now;
        }
    }
    while (die[0] < 2::second && die[1] < 2::second) {
        for (int j; j < 2; j++) {
            if (j == idx) {
                act[idx].hit(50);
            }
            50::ms + die[idx] => now;
        }
    }
    5::second => now;
}

// moving average filter
fun void decibelFilter(int idx) {
    int ctr;
    float sum;
    decibel_filter[idx].size() => int cap;
    while (true) {
        ana[idx].decibel() => decibel_filter[idx][ctr];
        (ctr + 1) % cap => ctr;
        0 => sum;
        for (int i; i < cap; i++) {
            decibel_filter[idx][i] +=> sum;
        }
        10::ms => now;
        sum/cap => decibel_average[idx];
        if (decibel_average[idx] == 0) {
            die[idx] + 1::ms => die[idx];
        }
        else if (die[idx] > 0::ms) {
            die[idx] - 1::ms => die[idx];
        }
    }
}

// after life
fun void postMortem(int idx) {
    <<< "~ postMortem -", idx, "-", stopwatch() >>>;
    int ctr;
    while (decibel_average[idx] == 0) {
        act[idx].envelope(15 + ctr, Math.random2(1, 4), 50::ms, 1000::ms);
        if (ctr < 20) {
            ctr++;
        }
    }
    1::second => now;
}

// main program
fun void life(int idx) {
    ana[idx].plugIn();
    bloodFlow(idx);
    heartStart(idx);
    heartPumping(idx);
    cardiacArrest(idx);
    postMortem(idx);
    bloodFlow(idx);
    <<< "~ end - ", idx, stopwatch >>>;
}

// sporks invdividual solenoids
spork ~ life(0);
spork ~ life(1);

// infinite loop
while (true) {
    1::second => now;
}
