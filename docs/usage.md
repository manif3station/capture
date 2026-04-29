# Usage

## Command

```bash
dashboard capture.run '<command block>'
```

## Command Block Rules

- one command works as a single-step capture
- separate commands with a blank line to run multiple steps in one transcript
- the current working directory is always recorded first through `pwd`

## Examples

Single command:

```bash
dashboard capture.run 'git status --short'
```

Two-step troubleshooting flow:

```bash
dashboard capture.run $'pwd\n\ngit status --short'
```

Write the transcript to a known path:

```bash
OUTPUT=/tmp/dd-capture.txt dashboard capture.run $'pwd\n\nenv | sort'
```

## Output Behavior

- stdout shows the transcript live
- the same transcript is written to the file named by `OUTPUT`
- if `OUTPUT` is unset, the skill uses a unique file under `/tmp/`
- when `OUTPUT` is unset, the command ends by printing `Capture saved to: /tmp/...`

## Failure Behavior

- missing command input returns a usage error
- command stderr is merged into stdout so the transcript is complete
