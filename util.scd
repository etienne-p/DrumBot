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


~save.value