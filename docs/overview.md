# Overview

`capture` is a troubleshooting helper skill.

It takes a shell command block, prepends `pwd`, prints each command inside a simple banner, executes the block with `bash`, and writes the combined transcript to a capture file.

The primary audience is developers or operators who need to share both:

- what they ran
- what the terminal printed back

That makes bug reports and support conversations easier to verify.
