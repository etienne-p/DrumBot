~make_slider = { |label, default, from, to, callback|
	var tf, num_box, slider;
	num_box = NumberBox().maxSize_(Size(50, 20));
	slider = Slider().action_({
		num_box.value = callback.value(from + (slider.value * (to - from)))});
	tf = StaticText().align_(\left).string_(label);
	slider.orientation = \horizontal;
	slider.value = (default - from) / (to - from);
	slider.action.value;
	GridLayout.rows([slider, num_box, tf]);
};

~exit_app = {
	Window.closeAll;
	Server.local.freeAll;
	Server.local.quit;
};

~save_settings = {
	Dialog.savePanel({|path|
		var config = List[
			\init_state, ~init_state,
			\rules, ~rules,
			\hotspots, ~hotspots,
			\synth_params, ~synth_params];
		var file = File.open(path, "w");
		file.write(Dictionary.newFrom(config).asCompileString);
		file.close;
		("Save settings at [" ++ path ++ "]").postln;
	}, {"Save canceled!".postln});
};