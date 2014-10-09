var main_window, rout, synth_symbols, synths, key_dict, volume;

// create synths
~synth_symbols = [\kick, \snare, \clap, \hat];
synths = Dictionary.newFrom(
	~synth_symbols.collect({|item, i|[item, Synth(item)] }).flat);
volume = Dictionary.newFrom(
	~synth_symbols.collect({|item, i|[item, 0.5] }).flat);

// main window
main_window = Window("main").onClose_(~exit_app).front;

key_dict = [
	\a, \kick,
	\s, \snare,
	\d, \clap,
	\f, \hat].as(Dictionary);

~play_drum = { |id, val|
	if (synths.at(id).isNil.not) {
		synths[id].set(\t_gate, val * volume[id]) };
};

main_window.view.keyDownAction = { |v, key|
	var synth = key_dict.at(key.asSymbol);
	if (synth != nil) {~play_drum.value(synth, 1)};
};

// set synth params if they haven't been yet
(~synth_params.isNil).if({
	~synth_params = [
		\kick -> [
			[\brightness, 1.35, 0, 2],
			[\clickDecay, 0.001, 0, 0.05],
			[\thump, 0.04, 0.001, 0.3]],
		\snare -> [
			[\brightness, 0.5, 0, 2]],
		\clap -> [
			[\brightness, 0.5, 0, 2],
			[\bw, 0.5, 0.1, 4]],
		\hat -> [
			[\attack, 0.03, 0, 0.4],
			[\bw, 2.4, 0.1, 4]]];

	// add common parameters
	~synth_params.do({|assoc|
		assoc.value = assoc.value ++ [
			[\decay, 0.2, 0.01, 0.8],
			[\pitch, 1, 0.2, 2]];
	})
});

// build UI
main_window.layout = VLayout(*(~synth_params.collect({|assoc|
	assoc.value.collect({ |item, i|
		~make_slider.value(
			item[0], item[1], item[2], item[3],
			{|val| synths[assoc.key].set(item[0], val); item[1] = val; val; });
	}).addFirst(~make_slider.value(
			\volume, 0.5, 0, 1,
			{|val| volume[assoc.key] = val; val; }
	)).addFirst(StaticText().string_(assoc.key.asString))
}).flat));


