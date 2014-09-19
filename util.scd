
~make_slider = { |label, default, from, to, callback|
	var tf, num_box, slider;
	num_box = NumberBox();
	num_box.maxSize = Size(50, 20);
	slider = Slider()
	.action_({
		var val = from + (slider.value * (to - from));
		num_box.value_(val);
		callback.value(val);
	});
	tf = StaticText();
	tf.align = \left;
	tf.string = label;
	slider.orientation = \horizontal;
	slider.value = (default - from) / (to - from);
	slider.action.value;
	GridLayout.rows([slider, num_box, tf]);
}

