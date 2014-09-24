(
var columns = 48;
var rows = 48;
var side = 6;
var rect = Rect(0, 0, side, side);
var cells = Array.fill2D(rows, columns, { 2.rand });
var rules = Array.fill3D(2, 2, 2, 0);
var win_automata = Window("automata", Rect(0, 0, columns * side, rows * side)).front;
var win_rules_editor = Window("rules editor", Rect(0, 0, columns * side, rows * side)).front;
var sync_rules_on_editor, sync_editor_on_rules, input_fields;
var combinations =  {
	var rv = List();
	rules.do({|x, i|
		x.do({|y, j|
			y.do({|z, k|
				rv.add([i, j, k]);
			})
		})
	});
	rv;
}.();

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
		var comb = combinations[i];
		rules[comb[0]][comb[1]][comb[2]] = item.string.asInt.max(0).min(1);
	});
	sync_editor_on_rules.();
};

sync_editor_on_rules = {
	input_fields.do({|item, i|
		item.string = combinations.[i].inject(rules, _.at(_)).asString;
	})
};

// build rules editor ui
input_fields = Array.newClear(combinations.size);
win_rules_editor.layout = VLayout(*combinations.collect({|item, i |
	var tf = TextField(win_rules_editor).keyUpAction_(sync_rules_on_editor);
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
};

sync_editor_on_rules.();

{ while { win_automata.isClosed.not } { win_automata.refresh; 0.1.wait; } }.fork(AppClock)

)
