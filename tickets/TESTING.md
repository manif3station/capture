# Testing

## Policy

- tests run only inside Docker
- the shared test container definition lives at the workspace root
- this skill keeps its test files in `t/`

## Commands

```bash
docker compose -f ~/projects/skills/docker-compose.testing.yml run --rm perl-test bash -lc 'cd /workspace/skills/capture && cpanm --quiet --notest --installdeps . && prove -lr t'
docker compose -f ~/projects/skills/docker-compose.testing.yml run --rm perl-test bash -lc 'cd /workspace/skills/capture && cpanm --quiet --notest --installdeps . && cover -delete && HARNESS_PERL_SWITCHES=-MDevel::Cover prove -lr t && cover -report text -select_re "^lib/" -coverage statement -coverage subroutine'
```

## Latest Verification

- Date: 2026-04-29
- Functional test:
  - `docker compose -f ~/projects/skills/docker-compose.testing.yml run --rm perl-test bash -lc 'cd /workspace/skills/capture && cpanm --quiet --notest --installdeps . && prove -lr t'`
  - Result: pass
  - Test count: `Files=2, Tests=17`
- Coverage test:
  - `docker compose -f ~/projects/skills/docker-compose.testing.yml run --rm perl-test bash -lc 'cd /workspace/skills/capture && cpanm --quiet --notest --installdeps . && cover -delete && HARNESS_PERL_SWITCHES=-MDevel::Cover prove -lr t && cover -report text -select_re "^lib/" -coverage statement -coverage subroutine'`
  - Result: pass
  - Coverage: `100.0%` statement and `100.0%` subroutine for `lib/Capture/CLI.pm`
- Installed DD proof:
  - `dashboard skills install ~/projects/skills/skills/capture`
  - Result: pass, installed `capture` at version `0.01`
  - `dashboard which capture.run`
  - Result: pass, resolved `/home/mv/projects/skills/.developer-dashboard/skills/capture/cli/run`
  - `OUTPUT=/tmp/capture-proof.txt dashboard capture.run $'printf "proof\\n"\n\nfalse\n\nprintf "after\\n"'`
  - Result: pass, printed the transcript and wrote the same transcript to `/tmp/capture-proof.txt`
- Cleanup:
  - `docker compose -f ~/projects/skills/docker-compose.testing.yml run --rm perl-test bash -lc 'rm -rf /workspace/skills/capture/cover_db'`
  - Result: pass
