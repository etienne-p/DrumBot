var columns = 48;
var rows = 48;
var side = 6;
var rect = Rect(0, 0, side, side);
var cells = Array.fill2D(rows, columns, {2.rand});
var rules = Array.fill3D(2, 2, 2, 0);
var win_automata = Window("automata", Rect(0, 0, columns * side, rows * side)).front;
var win_rules_editor = Window("rules editor").front;
var slice_2D, sync_rules_on_editor, sync_editor_on_rules, input_fields, test_match;
var drag_origin;
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

// start with Wolfram rule 30
rules[0][0][0] = 0;
rules[0][1][0] = 1;
rules[1][0][0] = 1;
rules[0][0][1] = 1;
rules[1][0][1] = 0;
rules[1][1][0] = 0;
rules[0][1][1] = 1;
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

slice_2D = { |source, top, left, width, height|
	height.collect({|i| source[i].copyRange(left, left + width - 1)});
};

test_match = {|source, pattern, top, left|
	// does the pattern fits in the source?
	if (((left + pattern[0].size) <= source[0].size) &&
		((top + pattern.size) <= source.size)
	) {slice_2D(source, top, left, pattern) == pattern} {false};
};

// build rules editor ui
input_fields = Array.newClear(combinations.size);
win_rules_editor.layout = VLayout(*combinations.collect({|item, i |
	var tf = TextField().keyUpAction_(sync_rules_on_editor);
	input_fields.put(i, tf);
	GridLayout.rows([
		StaticText().string_(item.collect(_.asString).inject("", _++_)), tf]);
}));

// build automata ui
win_automata.drawFunc = {
	// update automata
	var f = cells.first;
	cells.addFirst(f.collect({ |item, i|
		[-1, 0, 1].collect(
			{|offset| f.at((i + offset).mod(columns))}
		).inject(rules, _.at(_));
	}));
	cells.pop;
	// draw automata
	cells.do({|row, i|
		row.do({| cell, j|
			rect.origin = (j * side)@( i * side);
			Pen.fillColor = Color(cell, cell, cell);
			Pen.fillRect(rect);
			Pen.fillStroke;
		})
	});
	// test pattern matches
	if (~hotspots.isNil.not){
		~hotspots.do({|spot, i|
			if (test_match(cells, spot.pattern, spot.origin.x, spot.origin.y)) { ("hit " ++ spot.id.asString).postln };
		})
	};
};

win_automata.view.mouseDownAction = { |view, x, y| drag_origin = x@y };

win_automata.view.mouseUpAction = { |view, x, y|

	(drag_origin.asString ++ "->" ++(x@y).asString).postln;
};

sync_editor_on_rules.value;

{ while { win_automata.isClosed.not } { win_automata.refresh; 0.1.wait; } }.fork(AppClock);
