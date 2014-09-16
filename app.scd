




//--------------------------------------------------------------------
(~make_slider = { |win, x, y, default, from, to, callback|
	var num_box, slider;
	num_box = NumberBox(win, Rect(x + 180, y, 40, 20));
	slider = Slider(win, Rect(x, y, 160, 20))
	.action_({
		var val = from + (slider.value * (to - from));
		num_box.value_(val);
		callback.value(val);
	});
	slider.value = (default - from) / (to - from);
	slider.action.value;
})

//--------------------------------------------------------------------


(

var main_window, cy, rout, hash, synths;

main_window = Window("main", Rect(0, 0, 400, 200)).front;

synths = Dictionary.newFrom(
	[\kick, \snare, \clap, \hat].collect({|item, i|[item, Synth(item)] }).flat);

hash = [
\kick -> [
	[\brightness, 0.5, 0, 1],
	[\thump, 0.1, 0.001, 0.3]],
\snare -> [
	[\brightness, 0.5, 0, 1]],
\clap -> [
	[\brightness, 0.5, 0, 1],
	[\bw, 0.5, 0.1, 2]]
];

cy = 0;

hash.do({|assoc|

	assoc.value.do({ |item, i|

		~make_slider.value(
			main_window, 0, cy, item[1], item[2], item[3],
			{|val| synths[assoc.key].set(item[0], val)});

		cy = cy + 30;
	});
});

rout = Routine({
	    loop({
				synths[\kick].set(\t_gate, 0.6);
		        0.2.wait;
	    })
}).play;

main_window.onClose = { rout.stop; };

)
