# 2026-05-13 Restore Live Stdout For Default Output Runs

## Summary

Restored live transcript printing for `dashboard capture.run` when `OUTPUT` is unset, while keeping the trailing `Capture saved to: /tmp/...` announcement.

## Why

Default-path runs regressed into printing only the saved-file notice, which broke the expected transcript-on-stdout behavior and the existing Docker test proof.

## Proof

- the default-output test again captures the command output on stdout
- the generated `/tmp/capture-...txt` path is still printed after the transcript
- the saved transcript file still contains the same command output as stdout
