var main_window, rout, synth_symbols, synths, key_dict, ui_elts;

// create synths
synth_symbols = [\kick, \snare, \clap, \hat];
synths = Dictionary.newFrom(
	synth_symbols.collect({|item, i|[item, Synth(item)] }).flat);

// main window
main_window = Window("main").front;
main_window.alwaysOnTop = true;

key_dict = [
	\a, \kick,
	\s, \snare,
	\d, \clap,
	\f, \hat].as(Dictionary);

main_window.view.keyDownAction = { |v, key|
	var synth = key_dict.at(key.asSymbol);
	if (synth != nil) { synths[synth].set(\t_gate, 0.6) };
};

~hotspot_handler = { |id, val|
	if (synths.at(id).isNil.not) {
		synths[id].set(\t_gate, (val / 4).min(1)) };
};


main_window.onClose = {
	Window.closeAll;
	Server.local.freeAll;
	Server.local.quit;
};

// describe specific synth parameters
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
});

// build UI
main_window.layout = VLayout(*(~synth_params.collect({|assoc|
	assoc.value.collect({ |item, i|
		~make_slider.value(
			item[0], item[1], item[2], item[3],
			{|val| synths[assoc.key].set(item[0], val); item[1] = val; val; });
	}).addFirst(StaticText().string_(assoc.key.asString))
}).flat));


