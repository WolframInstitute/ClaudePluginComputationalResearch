#!/usr/bin/env python3
"""Check scaffold behavior against human-edited files in disposable projects."""

import hashlib
from pathlib import Path
import subprocess
import tempfile
import unittest


SCRIPTS = Path(__file__).resolve().parent


def snapshot(folder):
    return {
        str(path.relative_to(folder)): hashlib.sha256(path.read_bytes()).hexdigest()
        for path in folder.rglob("*")
        if path.is_file()
    }


def run(name, *args):
    return subprocess.run(
        ["bash", str(SCRIPTS / name), *map(str, args)],
        capture_output=True,
        text=True,
        timeout=30,
    )


class ScaffoldPreservation(unittest.TestCase):
    def test_project_scaffolds_refuse_existing_targets(self):
        with tempfile.TemporaryDirectory(prefix="scaffold-preservation-") as folder:
            base = Path(folder)
            cases = [
                ("scaffold-paclet.sh", "Paclet", ["Paclet", "Org", "Test", "Author", "test@example.invalid", base / "solo"]),
                ("scaffold-paclet-dev.sh", "Dev", ["Dev", "One,Two", "Org", "user", "Test", "Author", "test@example.invalid", base / "dev"]),
                ("scaffold-project.sh", "Research", ["Research", "Test", base / "research", "Author", "test@example.invalid"]),
                ("scaffold-math-project.sh", "Math", ["Math", "Test", base / "math", "Author", "test@example.invalid"]),
            ]
            for script, name, args in cases:
                with self.subTest(script=script):
                    output = args[-1] if script.startswith("scaffold-paclet") else args[2]
                    project = Path(output) / name
                    first = run(script, *args)
                    self.assertEqual(first.returncode, 0, first.stderr)
                    (project / "README.md").write_text("Human README correction.\n")
                    code = next(project.rglob("Kernel/*.wl"), None)
                    if code is None:
                        code = project / "Code" / "Tools.wl"
                    code.write_text("(* Human code correction. *)\n")
                    before = snapshot(project)
                    second = run(script, *args)
                    self.assertNotEqual(second.returncode, 0)
                    self.assertEqual(snapshot(project), before)

    def test_journal_reruns_preserve_existing_content(self):
        with tempfile.TemporaryDirectory(prefix="journal-preservation-") as folder:
            for fmt, extension, macros in [("latex", "tex", "sty"), ("typst", "typ", "typ")]:
                with self.subTest(format=fmt):
                    project = Path(folder) / fmt
                    args = ["--" + fmt, project, "Test Journal", "Author"]
                    first = run("scaffold-journal.sh", *args)
                    self.assertEqual(first.returncode, 0, first.stderr)
                    journal = project / "Journal"
                    for name in [f"journal.{extension}", f"macros.{macros}", "references.bib"]:
                        (journal / name).write_text(f"Human correction to {name}.\n")
                    (journal / "entries" / "human-entry.txt").write_text("Human entry.\n")
                    before = snapshot(journal)
                    second = run("scaffold-journal.sh", *args)
                    self.assertEqual(second.returncode, 0, second.stderr)
                    self.assertEqual(snapshot(journal), before)


if __name__ == "__main__":
    unittest.main()
