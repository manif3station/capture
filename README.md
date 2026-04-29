# capture

## Description

`capture` is a Developer Dashboard skill that runs shell commands and captures the commands plus their output as a shareable troubleshooting transcript.

## Value

It gives developers and operators a quick way to reproduce a problem, show exactly what was run, and save the resulting terminal output into one transcript file they can share with somebody else.

## Problem It Solves

Troubleshooting often breaks down because a person shares only the output, only the command, or an incomplete sequence of steps. That makes it hard for another developer to replay the issue or trust the report.

## What It Does To Solve It

This skill runs a command block through `bash`, prints a formatted transcript to stdout, and writes the same transcript to a capture file. It also records the current working directory first so the receiver can see where the run started.

## Developer Dashboard Feature Added

This skill adds a CLI command:

- `dashboard capture.run`

## Installation

Install from the skill repo:

```bash
dashboard skills install git@github.mf:manif3station/capture.git
```

For local development in this workspace:

```bash
dashboard skills install ~/projects/skills/skills/capture
```

## How To Use It

Run a single command:

```bash
dashboard capture.run 'perl -e "print qq(hello\n)"'
```

Run more than one command by separating them with a blank line inside the same argument:

```bash
dashboard capture.run $'pwd\n\nls -1'
```

Control the saved transcript path:

```bash
OUTPUT=/tmp/capture-demo.txt dashboard capture.run $'pwd\n\nuname -a'
```

If `OUTPUT` is not set, the skill writes to a unique file under `/tmp/` and prints that saved file path at the end so the user can find it again.

## Normal Cases

```text
Use one command when you want to show a single failing step and its output.
```

```text
Use a blank-line-separated command block when you want to show a short troubleshooting flow in one transcript.
```

```text
Set `OUTPUT=/tmp/name.txt` when you want a predictable file path to attach or paste elsewhere.
```

## Edge Cases

```text
If no command block is provided, the skill exits non-zero and prints usage guidance.
```

```text
If one command in the block fails, the transcript still captures the output produced before and after that failure because the shell script keeps running line by line.
```

```text
If the caller does not set `OUTPUT`, the saved transcript path is unique but not deterministic.
```

```text
When `OUTPUT` is not set, the command ends by printing `Capture saved to: /tmp/...` so the user can find the generated transcript file.
```

## Docs

- `docs/overview.md`
- `docs/usage.md`
- `docs/changes/2026-04-29-initial-release.md`
