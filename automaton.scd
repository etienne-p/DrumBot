(

var columns = 16;
var rows = 16;
var side = 20;
var rect = Rect(0, 0, side, side);
var cells = Array.fill2D(rows, columns, { 2.rand });
var rules = Array.fill3D(2, 2, 2, {0});
var w = Window("view", Rect(0, 0, columns * side, rows * side)).front;

// rule 30
rules[0][0][0] = 0;
rules[0][1][0] = 1;
rules[1][0][0] = 1;
rules[0][0][1] = 1;
rules[1][0][1] = 0;
rules[1][1][0] = 0;
rules[0][1][1] = 1;
rules[1][1][1] = 0;

w.drawFunc = {

	var f = cells.first;
	cells.addFirst(f.collect({ |item, i|
		var prevStates = [-1, 0, 1].collect(
			{|offset| f.at((i + offset).mod(columns))});
		prevStates.inject(rules, _.at(_));
	}));

	cells.pop;

	cells.do({|row, i|
		row.do({| cell, j|
			rect.origin = (j * side)@( i * side);
			Pen.fillColor = Color(cell, cell, cell);
			Pen.fillRect(rect);
			Pen.fillStroke;
		})
	});
};

{ while { w.isClosed.not } { w.refresh; 0.5.wait; } }.fork(AppClock)

)
