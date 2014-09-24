var win_hotspots = Window("hotspots").front;
var add_hotspot_editor;

~hotspots = [\kick, \snare, \clap, \hat].collect({|item| (
	id: item,
	origin: 0@0,
	pattern: [[0]])});

add_hotspot_editor = {|hotspot|








};

win_hotspots.layout = VLayout(*~hotspots.collect({|item, i| add_hotspot_editor(item)})); // use syntax shortcut