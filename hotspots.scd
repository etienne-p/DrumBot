var win_hotspots = Window("hotspots").front;
var add_hotspot_editor;

~hotspots = [\kick, \snare, \clap, \hat].collect({|item| (
	id: item,
	origin: 0@0,
	pattern: [[0]])});

add_hotspot_editor = {|hotspot|



slice_2D = { |source, top, left, width, height|
	height.collect({|i| source[i].copyRange(left, left + width - 1)});
};

test_match = {|source, pattern, top, left|
	// does the pattern fits in the source?
	if (((left + pattern[0].size) <= source[0].size) &&
		((top + pattern.size) <= source.size)
	) {slice_2D(source, top, left, pattern) == pattern} {false};
};








};

win_hotspots.layout = VLayout(*~hotspots.collect({|item, i| add_hotspot_editor(item)})); // use syntax shortcut