SynthDef(\kick, {|out=#[0, 1], decay = 0.5, pitch = 1, t_gate = 0, brightness = 1, thump = 0.1, clickDecay = 0.001|

	var freqEnv, sine, ampEnv, clickEnv, click;
	freqEnv = Env.perc(0.0, thump, t_gate, -4);
	clickEnv = Env.perc(0.0, clickDecay, t_gate, -4);
	ampEnv = Env.perc(0.0, decay, t_gate, 2);
	sine = SinOsc.ar(
		EnvGen.kr(freqEnv, t_gate, 12, 1) * 40 * pitch,
		0,
		EnvGen.kr(ampEnv, t_gate));
	click = BBandPass.ar(WhiteNoise.ar(), 3000 * pitch, 0.5, EnvGen.kr(clickEnv, t_gate));
	Out.ar(out, (sine + (click * brightness)));
}).store;

SynthDef(\clap, {|out=#[0, 1], decay = 0.5, pitch = 1, t_gate = 0, brightness = 1, bw = 0.5|

	var sawEnv, env, noise, saw, sawFreq = 100;
	//-- 3 saw periods
	sawEnv = Env([0, 1, 0, 1, 0, 1, 0, 1, 0], [0, 1, 0, 1, 0, 1, 0, 1000]);

	env = Env.perc(0, decay, t_gate, -4);
	saw = EnvGen.ar(sawEnv, t_gate, 1, 0, 1/sawFreq);
	noise = saw * WhiteNoise.ar();
	noise = BBandPass.ar(noise, 1200 * pitch, bw, bw.reciprocal) +
	(brightness * (saw * BBandPass.ar(noise, 6000 * pitch, bw, bw.reciprocal)));
	Out.ar(out, (noise * EnvGen.ar(env, t_gate)));
}).store;

SynthDef(\snare, {|out=#[0, 1], decay = 0.5, pitch = 1, t_gate = 0, brightness = 1|

	var pulse, noise, noiseEnv, rez, ampHiEnv, ampLoEnv, res = 20;
	ampHiEnv = Env.perc(0.0, decay * 0.3, t_gate, -2);
	ampLoEnv = Env.perc(0.025, decay * 0.3, t_gate, -1);
	noiseEnv = Env.perc(0.0, decay, t_gate, -2);
	noise = WhiteNoise.ar(0.5 * EnvGen.kr(noiseEnv, t_gate));
	noise = BHiPass.ar(noise, 4000, 0.5);
	pulse = Trig.ar(t_gate, 0.001);
	rez = Resonz.ar(pulse, pitch * 180, res.reciprocal, res * EnvGen.kr(ampLoEnv, t_gate));
	rez = rez + Resonz.ar(pulse, 330 * pitch, res.reciprocal, 0.6 * res * EnvGen.kr(ampHiEnv, t_gate));
	rez = rez + (noise * brightness);
	Out.ar(out, BLowPass.ar(rez, 12000));
}).store;

SynthDef(\hat, {|out=#[0, 1], decay = 0.5, pitch = 1, t_gate = 0, attack = 0.05, bw = 0.5|
	var env, noise;
	env = Env.perc(attack, decay, t_gate, -2);
	noise = WhiteNoise.ar(EnvGen.kr(env, t_gate));
	Out.ar(out, BBandPass.ar(noise, 8000 * pitch, bw, bw.reciprocal));
}).store;



