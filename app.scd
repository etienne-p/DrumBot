




//--------------------------------------------------------------------
(
~make_slider = { |win, x, y, label, default, from, to, callback|
	var tf, num_box, slider;
	num_box = NumberBox(win, Rect(x + 160, y, 40, 20));
	slider = Slider(win, Rect(x, y, 160, 20))
	.action_({
		var val = from + (slider.value * (to - from));
		num_box.value_(val);
		callback.value(val);
	});
	tf = StaticText(win, Rect(x + 210, y, 120, 20));
	tf.align = \left;
	tf.string = label;
	slider.value = (default - from) / (to - from);
	slider.action.value;
}
)

//--------------------------------------------------------------------
(

var main_window, rout, hash, synthSymbols, synths, sub_windows;

// create synths
synthSymbols = [\kick, \snare, \clap, \hat];
synths = Dictionary.newFrom(
	synthSymbols.collect({|item, i|[item, Synth(item)] }).flat);

// describe specific synth parameters
hash = [
\kick -> [
	[\brightness, 0.5, 0, 1],
	[\thump, 0.1, 0.001, 0.3]],
\snare -> [
	[\brightness, 0.5, 0, 1]],
\clap -> [
	[\brightness, 0.5, 0, 1],
	[\bw, 0.5, 0.1, 4]],
\hat -> [
	[\attack, 0.05, 0, 0.4]]
];

// add common parameters
hash.do({|assoc|
	assoc.value = assoc.value ++ [
		[\decay, 0.2, 0.01, 0.8],
		[\pitch, 1, 0.2, 2]];
});

// build UI
sub_windows = List();
hash.do({|assoc|
	// for each instrument, create a window...
	var win = Window(
		assoc.key.asString,
		Rect(0, 0, 400, 30 * assoc.value.size), false).front;

	win.userCanClose = false;

	assoc.value.do({ |item, i|
		// ...add a slider per parameter
		~make_slider.value(
			win, 0, i * 30,
			(assoc.key.asString + "/" + item[0]),
			item[1], item[2], item[3],
			{|val| synths[assoc.key].set(item[0], val)});
	});
	sub_windows.add(win);
});

// test sound
rout = Routine({
	    loop({
				synths[synthSymbols.choose].set(\t_gate, 0.6);
		        0.2.wait;
	    })
}).play;

// main window
main_window = Window("main", Rect(0, 0, 220, 50)).front;
main_window.alwaysOnTop = true;
main_window.onClose = { rout.stop; Window.closeAll; };


// place subwindows on screen
Button(main_window, Rect(10, 10, 200, 30))
        .states_([ ["place windows", Color.black, Color.white]]).action_({
	var sumH = 0;
	sub_windows.do({|item, i|
		item.setTopLeftBounds(Rect(
			0,
			sumH,
			item.bounds.width,
			item.bounds.height
		));
		sumH = sumH + item.bounds.height + 50;
		item.front;
	});
});


)
