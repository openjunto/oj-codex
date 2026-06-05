#!/usr/bin/env bash
# contracts.sh — pinned-string CONTRACTS shared between oj-helper and tests.
#
# Each constant below is a CONTRACT: it appears in user-visible output AND is
# pattern-matched by the test harness, the structural validator, and the
# /oj:health-check skill. Edits MUST be coordinated:
#
#   1. Update the constant here.
#   2. Run scripts/validate-plugin.sh (drift canary greps bin/oj-helper for the
#      literal — fails loudly if the helper has not been updated).
#   3. Run scripts/tests/oj-helper-hook-test.sh + plugin-validate-test.sh.
#
# This file is sourced (not executed). It must remain side-effect-free at the
# top level: declare constants only.

# ────────────────────────────────────────────────────────────────────
# OJ_STDERR_CONDUCTOR_MISSING
# ────────────────────────────────────────────────────────────────────
# Stable stderr advisory emitted by `oj-helper conductor-inject` when
# CONDUCTOR.md is absent or unreadable. The em-dash is intentional.
readonly OJ_STDERR_CONDUCTOR_MISSING="OpenJunto: CONDUCTOR.md missing — manager protocol will not be injected this session"
