(
var basePath = PathName(thisProcess.nowExecutingPath).pathOnly;
var files = ["synthdefs", "util", "app"];
s.boot;
files.do({ |item, i|  thisProcess.interpreter.executeFile(basePath ++ item ++ ".scd"); });
)
