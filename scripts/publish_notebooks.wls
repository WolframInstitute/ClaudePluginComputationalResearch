#!/usr/bin/env wolframscript

(* publish_notebooks.wls — Build .nb from Wiki/Notebooks/*.md and upload to Wolfram Cloud *)

root = DirectoryName[$ScriptCommandLine[[1]]];
wikiDir = FileNameJoin[{root, "Wiki", "Notebooks"}];
nbDir = FileNameJoin[{root, "Notebooks"}];

(* First generate notebooks from wiki sources *)
Print["Building notebooks from wiki sources..."];
RunProcess[{"wolframscript", "-file", FileNameJoin[{root, "Scripts", "generate_notebooks.wls"}]}];

nbFiles = FileNames["*.nb", nbDir];

If[nbFiles === {},
	Print["No .nb files found in ", nbDir];
	Exit[1]
];

(* Determine cloud folder name from project *)
projectName = FileBaseName[root];

Print[""];
Print["Notebook Publisher"];
Print["=================="];
Print["Project: ", projectName];
Print[""];

results = {};

Do[
	baseName = FileBaseName[nbFile];
	Print["[", baseName, "] Uploading..."];
	cloudObj = CloudObject[projectName <> "/" <> baseName <> ".nb", Permissions -> "Public"];
	CopyFile[nbFile, cloudObj, OverwriteTarget -> True];
	Print["[", baseName, "] Published: ", First[cloudObj]];
	Print[""];
	AppendTo[results, baseName -> ToString[First[cloudObj]]],
	{nbFile, nbFiles}
];

Print["=================="];
Do[Print["  ", r[[1]], ": ", r[[2]]], {r, results}];
