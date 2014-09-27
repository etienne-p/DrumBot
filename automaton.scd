var columns = 48;
var rows = 48;
var side = 6;
var hit_threshold = 1;
var rect = Rect(0, 0, side, side);
var cells = Array.fill2D(rows, columns, {2.rand});
var rules = Array.fill3D(2, 2, 2, 0);
var win_automata = Window("automata", Rect(0, 0, columns * side, rows * side)).front;
var win_rules_editor = Window("rules editor").front;
var win_hotspots_editor = Window("hotspots editor").front;
var sync_rules_on_editor, sync_editor_on_rules, input_fields;

var default_hotspot_handler = {|id, val|("Hit " ++ id.asString ++ " [" ++ val.asString ++ "]").postln};

var hotspots = [\kick, \snare, \clap, \hat].collect({|item|(
	id: item,
	index: columns.rand,
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

sync_rules_on_editor = {
	input_fields.collect({|item, i|
		{|j, k, l| rules[j][k][l] = item.string.asInt.max(0).min(1)}.(*combinations[i]);
	});
	cells.first.do({|item, i| cells.first[i] = 2.rand});
	sync_editor_on_rules.value;
};

sync_editor_on_rules = {
	input_fields.do({|item, i|
		item.string = combinations.[i].inject(rules, _.at(_)).asString;
	})
};

// build rules editor ui
input_fields = Array.newClear(combinations.size);
win_rules_editor.layout = VLayout(*combinations.collect({|item, i |
	var tf = TextField().keyUpAction_(sync_rules_on_editor);
	input_fields.put(i, tf);
	GridLayout.rows([
		StaticText().string_(item.collect(_.asString).inject("", _++_)), tf]);
}));

// build hotspot editor ui
win_hotspots_editor.layout = VLayout(*hotspots.collect({ |item, i|
	~make_slider.value(
		item.id.asString, item.index, 0, columns - 1,
		{|val| item.index = val.floor; item.index; })
}));

// build automata ui
win_automata.drawFunc = {
	// update automata
	var row = cells.first;
	cells.addFirst(row.collect({ |item, i|
		[-1, 0, 1].collect(
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
		var row = cells.last;
		{row.at(item.index + hit).isInteger.if(
			{(row.at(item.index + hit) > 0)},
			{false})}.while({hit = hit + 1});
		// draw hotspot
		rect.origin = ((item.index) * side)@((rows - 1) * side);
		rect.width = hit.max(1) * side;
		Pen.fillColor = item.color;
		Pen.fillRect(rect);
		Pen.fillStroke;
		item.id.asString.drawAtPoint(rect.origin + (0@(-12)));
		if (hit > hit_threshold) {
			~hotspot_handler.isNil.if({default_hotspot_handler}, {~hotspot_handler}).value(item.id, hit - 1) };
	});
};

sync_editor_on_rules.value;

{ while { win_automata.isClosed.not } { win_automata.refresh; 0.1.wait; } }.fork(AppClock);
