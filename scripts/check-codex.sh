#!/usr/bin/env bash

set -euo pipefail

BUNDLED_CODEX="/usr/lib/chatgpt/resources/codex"

echo "========================================"
echo " Forge ChatGPT - Codex controle"
echo "========================================"
echo

if command -v codex >/dev/null 2>&1; then
    CODEX_BIN="$(command -v codex)"

    echo "Codex CLI gevonden in PATH"
    echo "$CODEX_BIN"
    echo

    "$CODEX_BIN" --version
    exit 0
fi

if [[ -x "$BUNDLED_CODEX" ]]; then
    echo "Codex CLI gevonden in ChatGPT Desktop:"
    echo "$BUNDLED_CODEX"
    echo

    "$BUNDLED_CODEX" --version
    exit 0
fi

echo "Codex CLI niet gevonden."
exit 1
