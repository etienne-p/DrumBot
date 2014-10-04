var columns = 14;
var rows = 24;
var side = 16;
var rect = Rect(0, 0, side, side);
var cells = Array.fill2D(rows, columns, {2.rand});
var rules = Array.fill3D(2, 2, 2, 0);
var win_automata = Window("automata", Rect(0, 0, columns * side, rows * side)).front;
var win_editor = Window("editor").front;
var sync_rules_on_editor, sync_editor_on_rules, sync_init_on_buttons, input_fields, init_buttons, tempo_slider;

//var default_hotspot_handler = {|id, val|("Hit " ++ id.asString ++ " [" ++ val.asString ++ "]").postln};
// TODO: remove it?
var default_hotspot_handler = {};

var hotspots = [\kick, \snare, \clap, \hat].collect({|item, i|(
	id: item,
	hit_threshold: 4 - i,
	position: (columns.rand)@(rows.rand),
	color: Color(*Array.fill(3, {1.0.rand})))
});
//var drag_origin;
var combinations = {
	var rv = List();
	rules.do({|x, i|
		x.do({|y, j|
			y.do({|z, k|
				rv.add([i, j, k]);
			})
		})
	});
	rv;
}.value;

// da rule
rules[0][0][0] = 1;
rules[0][1][0] = 0;
rules[0][1][0] = 0;
rules[0][1][1] = 1;
rules[1][0][0] = 0;
rules[1][0][1] = 0;
rules[1][1][0] = 1;
rules[1][1][1] = 0;

input_fields = Array.newClear(combinations.size);

sync_rules_on_editor = {
	input_fields.collect({|item, i|
		{|j, k, l| rules[j][k][l] = item.string.asInt.max(0).min(1)}.(*combinations[i]);
	});
	sync_init_on_buttons.value;
	sync_editor_on_rules.value;
};

sync_editor_on_rules = {
	input_fields.do({|item, i|
		item.string = combinations.[i].inject(rules, _.at(_)).asString;
	})
};

sync_init_on_buttons = {
	init_buttons.do({|item, i|
		cells.first.put(i, item.value.asInteger);
	})
};

init_buttons = columns.collect({ Button()
        .states_([
		["0", Color.white, Color.black],
		["1", Color.black, Color.white]
	]).action_(sync_init_on_buttons)
});

tempo_slider = Slider().orientation_(\horizontal);
tempo_slider.value = 0.5;

win_editor.layout = VLayout(
	HLayout(
		// build rules editor ui
		VLayout(*combinations.collect({|item, i |
			var tf = TextField().keyUpAction_(sync_rules_on_editor);
			input_fields.put(i, tf);
			GridLayout.rows([
				StaticText().string_(item.collect(_.asString).inject("", _++_)), tf]);
		})),
		// build hotspot editor ui
		VLayout(*(hotspots.collect({ |item, i|
			var slider = Slider2D().action_({|sl|
				item.position = ((sl.x * (columns - 1)).round)@(((1 - sl.y) * (rows - 1)).round)});
			var text = StaticText().string_(item.id.asString);
			slider.setXY(1.0.rand, 1.0.rand);
			slider.action.value(slider);
			[text, slider];
	})).flat)),
	VLayout(
		// init conditions
		HLayout(*init_buttons).spacing_(1),
		Slider().orientation_(\horizontal).action_({|sl|
			var index = (sl.value * (columns - 1)).round;
			init_buttons.do({|item, i| item.value = if(i == index, 1, 0)});
			sync_init_on_buttons.value;
		}),
		tempo_slider
	)
);
// build automata ui
win_automata.drawFunc = {
	// update automata
	var row = cells.first;
	cells.addFirst(row.collect({ |item, i|
		(-1..1).collect(
			{|offset| row.at((i + offset).mod(columns))}
		).inject(rules, _.at(_));
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
	hotspots.do({|item|
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
			~play_drum.isNil.if({default_hotspot_handler}, {~play_drum}).value(item.id, 1) };
	});
};

sync_editor_on_rules.value;

{ while { win_automata.isClosed.not } { win_automata.refresh; (tempo_slider.value * 0.2).wait; } }.fork(AppClock);
