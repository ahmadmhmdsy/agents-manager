#!/usr/bin/env bash
# Backward-compat shim (v0.9.x). v0.10.0+ delegates everything to agents-manager.
# Use `bash explicit` instead of `exec` so the dispatcher file does not need
# the +x bit (Windows Git Bash checkouts often lack it; CI may not chmod it).
bash "$(dirname "${BASH_SOURCE[0]}")/agents-manager" install "$@"