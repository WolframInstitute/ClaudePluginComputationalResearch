$pacletDir = DirectoryName[ DirectoryName[ $InputFileName ] ];
PacletDirectoryLoad[ $pacletDir ];
Needs[ "{{ORG_NAME}}`{{PACLET_NAME}}`" ];

$testDir = DirectoryName[ $InputFileName ];
$testFiles = FileNames[ "*.wlt", $testDir ];

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
    Print[ "\nAll tests passed." ],
    Print[ "\nSome tests failed." ]
]
