var main_window, rout, synth_params, synth_symbols, synths, key_dict, ui_elts;

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

main_window.view.keyDownAction = { |v, key, mod|
	var synth = key_dict.at(key.asSymbol);
	if (synth != nil) { synths[synth].set(\t_gate, 0.6) };
};

main_window.onClose = {
	Window.closeAll;
	Server.freeAll();
};

// describe specific synth parameters
synth_params = [
	\kick -> [
		[\brightness, 0.5, 0, 2],
		[\clickDecay, 0.001, 0, 0.05],
		[\thump, 0.1, 0.001, 0.3]],
	\snare -> [
		[\brightness, 0.5, 0, 2]],
	\clap -> [
		[\brightness, 0.5, 0, 2],
		[\bw, 0.5, 0.1, 4]],
	\hat -> [
		[\attack, 0.05, 0, 0.4],
		[\bw, 0.5, 0.1, 4]]];

// add common parameters
synth_params.do({|assoc|
	assoc.value = assoc.value ++ [
		[\decay, 0.2, 0.01, 0.8],
		[\pitch, 1, 0.2, 2]];
});

// build UI
ui_elts = List();
synth_params.do({|assoc|
	var tf = StaticText();
	tf.string = assoc.key.asString;
	ui_elts.add(tf);
	assoc.value.do({ |item, i|
		// ...add a slider per parameter
		ui_elts.add(
			~make_slider.value(
				item[0], item[1], item[2], item[3],
				{|val| synths[assoc.key].set(item[0], val)}));
	});
});

main_window.layout = VLayout(*ui_elts);
