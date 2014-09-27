(
var basePath = PathName(thisProcess.nowExecutingPath).pathOnly;
var files = ["util", "synthdefs", "app", "automaton"];
Server.local.boot;
Server.local.waitForBoot(
	{files.do({ |item, i|  thisProcess.interpreter.executeFile(basePath ++ item ++ ".scd") })},
	60, { "Server wait for boot timed out"});
)
