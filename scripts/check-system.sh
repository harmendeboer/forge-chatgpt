#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"

CHATGPT_PACKAGE="chatgpt"
BUNDLED_CODEX="/usr/lib/chatgpt/resources/codex"
CHROMIUM_ID="org.chromium.Chromium"
APPLICATION_DIR="$HOME/.local/share/applications"

print_item() {
    printf "  %-22s : %s\n" "$1" "$2"
}

find_chatgpt_pwa() {
    local launcher

    shopt -s nullglob

    for launcher in "$APPLICATION_DIR"/org.chromium.Chromium*.desktop; do
        if grep -Fqx 'Name=ChatGPT' "$launcher" 2>/dev/null; then
            printf '%s\n' "$launcher"
            shopt -u nullglob
            return 0
        fi
    done

    shopt -u nullglob
    return 1
}

echo "========================================"
echo " Forge ChatGPT - Systeemcontrole"
echo "========================================"
echo

# --------------------------------------------------
# Systeem
# --------------------------------------------------

OS_NAME="Onbekend"
OS_VERSION="Onbekend"
OS_CODENAME="Onbekend"
UBUNTU_BASE="Onbekend"

if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    source /etc/os-release

    OS_NAME="${NAME:-Onbekend}"
    OS_VERSION="${VERSION_ID:-Onbekend}"
    OS_CODENAME="${VERSION_CODENAME:-Onbekend}"
    UBUNTU_BASE="${UBUNTU_CODENAME:-Onbekend}"
fi

if command -v dpkg >/dev/null 2>&1; then
    ARCHITECTURE="$(dpkg --print-architecture)"
else
    ARCHITECTURE="$(uname -m)"
fi

echo "Systeem"
print_item "Distributie" "$OS_NAME"
print_item "Versie" "$OS_VERSION"
print_item "Codenaam" "$OS_CODENAME"
print_item "Ubuntu basis" "$UBUNTU_BASE"
print_item "Architectuur" "$ARCHITECTURE"
echo

# --------------------------------------------------
# ChatGPT Desktop
# --------------------------------------------------

echo "ChatGPT Desktop"

PACKAGE_STATUS="$(
    dpkg-query -W -f='${db:Status-Abbrev}' "$CHATGPT_PACKAGE" 2>/dev/null || true
)"

if [[ "$PACKAGE_STATUS" == ii* ]]; then
    CHATGPT_VERSION="$(
        dpkg-query -W -f='${Version}' "$CHATGPT_PACKAGE"
    )"

    print_item "Status" "geïnstalleerd"
    print_item "Versie" "$CHATGPT_VERSION"
else
    print_item "Status" "niet geïnstalleerd"
fi

if command -v chatgpt >/dev/null 2>&1; then
    print_item "Executable" "$(command -v chatgpt)"
else
    print_item "Executable" "niet gevonden"
fi

echo

# --------------------------------------------------
# Codex
# --------------------------------------------------

echo "Codex"

CODEX_BIN=""

if command -v codex >/dev/null 2>&1; then
    CODEX_BIN="$(command -v codex)"
    CODEX_SOURCE="PATH"
elif [[ -x "$BUNDLED_CODEX" ]]; then
    CODEX_BIN="$BUNDLED_CODEX"
    CODEX_SOURCE="ChatGPT Desktop"
else
    CODEX_SOURCE="niet gevonden"
fi

if [[ -n "$CODEX_BIN" ]]; then
    CODEX_VERSION="$("$CODEX_BIN" --version 2>/dev/null || true)"

    print_item "Status" "gevonden"
    print_item "Bron" "$CODEX_SOURCE"
    print_item "Executable" "$CODEX_BIN"
    print_item "Versie" "$CODEX_VERSION"

    if command -v codex >/dev/null 2>&1; then
        print_item "In PATH" "ja"
    else
        print_item "In PATH" "nee"
    fi
else
    print_item "Status" "niet gevonden"
fi

echo

# --------------------------------------------------
# Developer tools
# --------------------------------------------------

echo "Developer tools"

if command -v git >/dev/null 2>&1; then
    print_item "Git" "$(git --version)"
else
    print_item "Git" "niet gevonden"
fi

if command -v gh >/dev/null 2>&1; then
    print_item "GitHub CLI" "$(gh --version | head -n 1)"
else
    print_item "GitHub CLI" "niet gevonden"
fi

if command -v code >/dev/null 2>&1; then
    print_item "VS Code" "$(code --version | head -n 1)"
else
    print_item "VS Code" "niet gevonden"
fi

echo

# --------------------------------------------------
# Forge repository
# --------------------------------------------------

echo "Forge repository"

if git -C "$PROJECT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    BRANCH="$(git -C "$PROJECT_DIR" branch --show-current)"

    print_item "Branch" "$BRANCH"

    if [[ -z "$(git -C "$PROJECT_DIR" status --porcelain)" ]]; then
        print_item "Werkmap" "clean"
    else
        print_item "Werkmap" "wijzigingen aanwezig"
    fi

    if git -C "$PROJECT_DIR" remote get-url origin >/dev/null 2>&1; then
        print_item "GitHub remote" "$(git -C "$PROJECT_DIR" remote get-url origin)"
    else
        print_item "GitHub remote" "niet ingesteld"
    fi
else
    print_item "Status" "geen Git-repository"
fi

echo

# --------------------------------------------------
# Legacy Chromium fallback
# --------------------------------------------------

echo "Legacy fallback"

if command -v flatpak >/dev/null 2>&1 &&
   flatpak info "$CHROMIUM_ID" >/dev/null 2>&1; then
    print_item "Chromium" "geïnstalleerd"
else
    print_item "Chromium" "niet geïnstalleerd"
fi

CHATGPT_PWA="$(find_chatgpt_pwa || true)"

if [[ -n "$CHATGPT_PWA" ]]; then
    print_item "ChatGPT PWA" "gevonden"
    print_item "PWA launcher" "$CHATGPT_PWA"
else
    print_item "ChatGPT PWA" "niet gevonden"
fi

echo
echo "========================================"
echo " Controle voltooid"
echo "========================================"
