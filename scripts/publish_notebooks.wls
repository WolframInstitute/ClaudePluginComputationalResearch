#!/usr/bin/env wolframscript

(* publish_notebooks.wls — Build .nb from an Artifacts folder's .md sources and
   upload to Wolfram Cloud. Publishing is never automatic: run this only when
   the user has asked for it. Pass the folder as the first argument to override
   the default Code/Artifacts. *)

(* Scripts live in <root>/Scripts/, so climb one level for the project root. *)
root = ParentDirectory[DirectoryName[$ScriptCommandLine[[1]]]];
nbDir = If[Length[$ScriptCommandLine] > 1,
	ExpandFileName[$ScriptCommandLine[[2]]],
	FileNameJoin[{root, "Code", "Artifacts"}]];

(* First generate notebooks from wiki sources *)
Print["Building notebooks from wiki sources..."];
RunProcess[{"wolframscript", "-file", FileNameJoin[{root, "Scripts", "generate_notebooks.wls"}], nbDir}];

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
