#!/usr/bin/env wolframscript

$pacletDir = DirectoryName[ $InputFileName ];
PacletDirectoryLoad[ $pacletDir <> "/{{PACLET_NAME}}" ];
Needs[ "{{ORG_NAME}}`{{PACLET_NAME}}`" ];

$testFiles = FileNames[ "*.wlt", FileNameJoin[ { $pacletDir, "{{PACLET_NAME}}", "Tests" } ] ];

$allPassed = True;
Do[
    report = TestReport[ file ];
    Print[ FileBaseName[ file ], ": ",
        report[ "TestsSucceededCount" ], "/",
        report[ "TestsSucceededCount" ] + report[ "TestsFailedCount" ] ];
    If[ report[ "AllTestsSucceeded" ] =!= True, $allPassed = False ],
    { file, $testFiles }
];

If[ $allPassed,
    Print[ "\nAll tests passed." ]; Exit[ 0 ],
    Print[ "\nSome tests failed." ]; Exit[ 1 ]
]
