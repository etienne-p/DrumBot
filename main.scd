(
var basePath = PathName(thisProcess.nowExecutingPath).pathOnly;

var start_app = {
	var files = ["util", "synthdefs", "app", "automaton"];
	"starting app.".postln;
	Server.local.boot;
	Server.local.waitForBoot(
		{files.do({ |item, i|
			thisProcess.interpreter.executeFile(basePath ++ item ++ ".scd") })},
		60, { "Server wait for boot timed out"});
};

var load_settings = {

	var on_cancel = {
		"No file selected, app will start with default settings.".postln;
		start_app.value;
	};

	var on_file_selected = {|path|
		var file = File.open(path, "r");
		var settings = file.readAllString.interpret;
		("loading settings file [" ++ path ++ "].").postln;
		file.close;
		~init_state = settings[\init_state];
		~rules = settings[\rules];
		~hotspots = settings[\hotspots];
		~synth_params = settings[\synth_params];
		start_app.value;
	};

	Dialog.openPanel(on_file_selected, on_cancel);
};

load_settings.value;
)






