

// a link between to blocks
var link = (
	from: blockId,
	to: blockId,
	weight: 0.5,
);

// render
var draw_kick, draw_kick, draw_clap, draw_hat;


var render = {

	// render blocks


	// render links

}

(
var b, a;
a = List.fill(4, (
	from: "f",
	to: "t",
	weight: 0.5
));
a = List.fill(3, {|i| (note: i, sustain: 1, dur: 1.5)});

a = List.fill(3, {|i| i});
b = Pseq(a, 2).asStream;
7.do({ b.next.postln; });
)

ListPattern.dumpClassSubtree;

Stream([0, 1])

a = Pmono(\default, \dur, 0.2, \freq, Pwhite(1,8) * 100 )

a = Routine.new({ 1.yield; 2.yield; });
a.next.postln;
a.next.postln;
a.next.postln;
"_".next.postln;



