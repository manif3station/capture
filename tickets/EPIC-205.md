# EPIC-205

## Title

Keep default `capture` runs mirroring live stdout.

## Goal

Preserve the transcript-on-stdout behavior for `dashboard capture.run` when `OUTPUT` is unset, without regressing the generated `/tmp` path announcement added in the prior ticket.
