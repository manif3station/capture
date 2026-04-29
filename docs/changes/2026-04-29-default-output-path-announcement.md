# 2026-04-29 Default Output Path Announcement

- changed `dashboard capture.run` to print the generated transcript file path at the end when `OUTPUT` is not set
- kept explicit `OUTPUT=...` runs unchanged so caller-managed transcript files still mirror stdout exactly
