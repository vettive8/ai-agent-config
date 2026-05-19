#!/usr/bin/env python3
"""
Run stack-aware repository checks for autonomous loops.

Examples:
    python agentic-dev-loop/scripts/run_repo_checks.py --mode quick
    python agentic-dev-loop/scripts/run_repo_checks.py --mode full --root .
"""

from __future__ import annotations

import argparse
import os
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable


@dataclass(frozen=True)
class Step:
    name: str
    command: list[str]
    mode: str = "quick"


def exists_any(root: Path, names: Iterable[str]) -> bool:
    return any((root / name).exists() for name in names)


def detect_node_pm(root: Path) -> str:
    if (root / "pnpm-lock.yaml").exists():
        return "pnpm"
    if (root / "yarn.lock").exists():
        return "yarn"
    if exists_any(root, ("bun.lockb", "bun.lock")):
        return "bun"
    return "npm"


def build_node_steps(root: Path) -> list[Step]:
    if not (root / "package.json").exists():
        return []
    pm = detect_node_pm(root)
    if pm == "yarn":
        return [
            Step("node-lint", ["yarn", "lint"], "quick"),
            Step("node-test", ["yarn", "test"], "quick"),
            Step("node-build", ["yarn", "build"], "full"),
        ]
    if pm == "bun":
        return [
            Step("node-lint", ["bun", "run", "lint"], "quick"),
            Step("node-test", ["bun", "test"], "quick"),
            Step("node-build", ["bun", "run", "build"], "full"),
        ]
    return [
        Step("node-lint", [pm, "run", "lint", "--if-present"], "quick"),
        Step("node-test", [pm, "run", "test", "--if-present"], "quick"),
        Step("node-build", [pm, "run", "build", "--if-present"], "full"),
    ]


def build_python_steps(root: Path) -> list[Step]:
    if not exists_any(root, ("pyproject.toml", "requirements.txt", "setup.py", "tox.ini")):
        return []
    steps: list[Step] = []
    if (root / "tests").exists() or (root / "pytest.ini").exists():
        steps.append(Step("python-test", ["python", "-m", "pytest"], "quick"))
    return steps


def build_go_steps(root: Path) -> list[Step]:
    if not (root / "go.mod").exists():
        return []
    return [
        Step("go-test", ["go", "test", "./..."], "quick"),
        Step("go-build", ["go", "build", "./..."], "full"),
    ]


def build_rust_steps(root: Path) -> list[Step]:
    if not (root / "Cargo.toml").exists():
        return []
    return [
        Step("rust-test", ["cargo", "test"], "quick"),
        Step("rust-build", ["cargo", "build"], "full"),
    ]


def build_dotnet_steps(root: Path) -> list[Step]:
    if not exists_any(root, ("global.json",)) and not list(root.glob("*.sln")):
        return []
    return [
        Step("dotnet-test", ["dotnet", "test"], "quick"),
        Step("dotnet-build", ["dotnet", "build"], "full"),
    ]


def build_java_steps(root: Path) -> list[Step]:
    if (root / "pom.xml").exists():
        return [
            Step("maven-test", ["mvn", "-q", "test"], "quick"),
            Step("maven-package", ["mvn", "-q", "-DskipTests", "package"], "full"),
        ]
    if (root / "gradlew").exists():
        wrapper = "./gradlew"
    elif (root / "gradlew.bat").exists():
        wrapper = ".\\gradlew.bat"
    elif (root / "build.gradle").exists() or (root / "build.gradle.kts").exists():
        wrapper = "gradle"
    else:
        return []
    return [
        Step("gradle-test", [wrapper, "test"], "quick"),
        Step("gradle-build", [wrapper, "build", "-x", "test"], "full"),
    ]


def discover_steps(root: Path, mode: str) -> list[Step]:
    all_steps: list[Step] = []
    for builder in (
        build_node_steps,
        build_python_steps,
        build_go_steps,
        build_rust_steps,
        build_dotnet_steps,
        build_java_steps,
    ):
        all_steps.extend(builder(root))
    if mode == "quick":
        return [step for step in all_steps if step.mode == "quick"]
    return all_steps


def run_step(step: Step, root: Path) -> tuple[str, int, str]:
    cmd_display = " ".join(step.command)
    print(f"\n[RUN] {step.name}: {cmd_display}")
    try:
        completed = subprocess.run(step.command, cwd=root, check=False)
        code = int(completed.returncode)
        if code == 0:
            print(f"[OK] {step.name}")
            return step.name, 0, "passed"
        print(f"[FAIL] {step.name} exited with {code}")
        return step.name, code, "failed"
    except FileNotFoundError:
        print(f"[SKIP] {step.name} command not found")
        return step.name, 127, "skipped"


def main() -> int:
    parser = argparse.ArgumentParser(description="Run stack-aware repository checks.")
    parser.add_argument(
        "--mode",
        default="quick",
        choices=("quick", "full"),
        help="quick: lint/test only; full: include build/package checks",
    )
    parser.add_argument(
        "--root",
        default=".",
        help="Repository root path (default: current directory)",
    )
    args = parser.parse_args()

    root = Path(args.root).resolve()
    if not root.exists() or not root.is_dir():
        print(f"[ERROR] Invalid root: {root}")
        return 2

    steps = discover_steps(root, args.mode)
    if not steps:
        print("[INFO] No known project markers found. Nothing to run.")
        return 0

    print(f"[INFO] Running {len(steps)} step(s) in {args.mode} mode from {root}")

    failures = 0
    skipped = 0
    for step in steps:
        _, code, status = run_step(step, root)
        if status == "failed":
            failures += 1
        elif status == "skipped":
            skipped += 1

    print("\n[SUMMARY]")
    print(f"mode={args.mode} total={len(steps)} failed={failures} skipped={skipped}")
    return 1 if failures else 0


if __name__ == "__main__":
    os.environ.setdefault("PYTHONUTF8", "1")
    sys.exit(main())
