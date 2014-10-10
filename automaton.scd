// Automaton
var columns = 32;
var rows = 24;
var side = 16;
var rect = Rect(0, 0, side, side);
var cells = Array.fill2D(rows, columns, {2.rand});
var combinations;
// UI
var win_automata = Window("Automaton", Rect(0, 0, columns * side, rows * side)).onClose_(~exit_app).front;
var win_editor = Window("Editor", Rect(0, 0, 600, 600)).onClose_(~exit_app).front;
var input_fields, init_buttons, tempo_slider;
// UI functions
var sync_rules_on_editor, sync_editor_on_rules, sync_init_on_buttons;

var default_hotspot_handler = {|id, val|("Hit " ++ id.asString ++ " [" ++ val.asString ++ "]").postln};

(~init_state.isNil).if({~init_state = Array.fill(columns, 2.rand)});

(~rules.isNil).if({
	~rules = Array.fill3D(2, 2, 2, 0);
	// da rule
	~rules[0][0][0] = 1;
	~rules[0][1][0] = 0;
	~rules[0][1][0] = 0;
	~rules[0][1][1] = 1;
	~rules[1][0][0] = 0;
	~rules[1][0][1] = 1;
	~rules[1][1][0] = 1;
	~rules[1][1][1] = 0;
});

(~hotspots.isNil).if({
	~hotspots = ~synth_symbols.collect({|item, i|(
		id: item,
		hit_threshold: 1,
		position: (columns.rand)@(rows.rand),
		color: Color.hsv(1.0.rand, 1.0, 1.0))
	})
});

combinations = {
	var rv = List();
	~rules.do({|x, i|
		x.do({|y, j|
			y.do({|z, k|
				rv.add([i, j, k]);
			})
		})
	});
	rv;
}.value;

input_fields = Array.newClear(combinations.size);

sync_rules_on_editor = {
	input_fields.collect({|item, i|
		{|j, k, l| ~rules[j][k][l] = item.string.asInt.max(0).min(1)}.(*combinations[i]);
	});
	sync_init_on_buttons.value;
	sync_editor_on_rules.value;
};

sync_editor_on_rules = {
	input_fields.do({|item, i|
		item.string = combinations.[i].inject(~rules, _.at(_)).asString;
	})
};

sync_init_on_buttons = {
	init_buttons.do({|item, i|
		~init_state[i] = item.value.asInteger; // for backup
		cells.first.put(i, item.value.asInteger);
	})
};

init_buttons = columns.collect({Button().maxWidth_(18)
        .states_([
		["0", Color.white, Color.black],
		["1", Color.black, Color.white]
	]).action_(sync_init_on_buttons)
});

tempo_slider = Slider().orientation_(\horizontal);
tempo_slider.value = 0.5;

win_editor.layout = VLayout(
	// build ~rules editor ui
	StaticText().string_("Automaton rules"),
	HLayout(*combinations.collect({|item, i |
		var tf = TextField().keyUpAction_(sync_rules_on_editor);
		input_fields.put(i, tf);
		GridLayout.columns([
			StaticText().string_(item.collect(_.asString).inject("", _++_)), tf]);
	})),
	// init conditions
	StaticText().string_("Automaton initial state"),
	HLayout(*init_buttons).spacing_(1),
	Slider().orientation_(\horizontal).action_({|sl|
		var index = (sl.value * (columns - 1)).round;
		init_buttons.do({|item, i| item.value = if(i == index, 1, 0)});
		sync_init_on_buttons.value;
	}),
	// tempo control
	StaticText().string_("Tempo"),
	tempo_slider,
	// build hotspot editor ui
	StaticText().string_("Hotspots"),
	VLayout(*(~hotspots.collect({ |item, i|
		var trig_slider = Slider().orientation_(\horizontal).action_({|sl|
			item.hit_threshold = (1 + (sl.value * 5)).floor});
		var pos_slider = Slider2D().action_({|sl|
			item.position = ((sl.x * (columns - 1)).round)@(((1 - sl.y) * (rows - 1)).round)});
		pos_slider.setXY(item.position.x / (columns - 1), 1 - (item.position.y / (rows - 1)));
		trig_slider.value = (item.hit_threshold - 1) / 5;
		//pos_slider.action.value(pos_slider);
		VLayout(
			StaticText().string_(item.id.asString ++ " trigger threshold"),
			trig_slider,
			StaticText().string_(item.id.asString ++ " trigger position"),
			pos_slider);
	}).clump(2).collect({|sub| HLayout(*sub)}))),
	Button().states_([["Save settings"]]).action_(~save_settings)
);
// build automata ui
win_automata.drawFunc = {
	// update automata
	var row = cells.first;
	cells.addFirst(row.collect({ |item, i|
		(-1..1).collect(
			{|offset| row.at((i + offset).mod(columns))}
		).inject(~rules, _.at(_));
	}));
	cells.pop;
	// draw automata
	cells.do({|row, i|
		row.do({| cell, j|
			rect.origin = (j * side)@( i * side);
			Pen.fillColor = Color(cell * 0.2, cell * 0.2, cell * 0.2);
			Pen.fillRect(rect);
			Pen.fillStroke;
		})
	});
	// handle hotspots
	~hotspots.do({|item|
		// eval hotspot
		var hit = 0;
		var row = cells.at(item.position.y);
		{row.at(item.position.x + hit).isInteger.if(
			{(row.at(item.position.x + hit) > 0)},
			{false})}.while({hit = hit + 1});
		// draw hotspot
		rect.origin = ((item.position.x) * side)@((item.position.y) * side);
		rect.width = item.hit_threshold * side;
		Pen.fillColor = item.color;
		Pen.fillRect(rect);
		Pen.fillStroke;
		item.id.asString.drawAtPoint(rect.origin + (0@(-12)));
		if (hit >= item.hit_threshold) {
			~play_drum.isNil.if(
				{default_hotspot_handler},
				{~play_drum}).value(item.id, (hit / 4.0).min(1.0)) };
	});
};

// Init editor
sync_editor_on_rules.value;

// Init automaton
init_buttons.do({|btn, i| btn.value = ~init_state[i]});
sync_init_on_buttons.value;

{ while
	{ win_automata.isClosed.not.and(win_editor.isClosed.not) }
	{ win_automata.refresh; (tempo_slider.value * 0.2).wait; }
}.fork(AppClock);
