#!/usr/bin/env bash

set -Eeuo pipefail

CHROMIUM_ID="org.chromium.Chromium"

APPLICATION_DIR="$HOME/.local/share/applications"
LEGACY_LAUNCHER="$APPLICATION_DIR/chatgpt.desktop"
LEGACY_ICON_DIR="$HOME/.local/share/icons/chatgpt"

trap 'echo; echo "Fout op regel $LINENO. Verwijderen is gestopt."; exit 1' ERR

find_chatgpt_launcher() {
    local launcher

    shopt -s nullglob

    for launcher in "$APPLICATION_DIR"/org.chromium.Chromium*.desktop; do
        if grep -Fqx 'Name=ChatGPT' "$launcher"; then
            printf '%s\n' "$launcher"
            shopt -u nullglob
            return 0
        fi
    done

    shopt -u nullglob
    return 1
}

echo "======================================"
echo " Forge ChatGPT verwijderen"
echo "======================================"
echo

CHATGPT_LAUNCHER="$(find_chatgpt_launcher || true)"

if [[ -z "$CHATGPT_LAUNCHER" ]]; then
    echo "Er is geen actieve ChatGPT-webapp gevonden."
else
    echo "Gevonden Chromium-launcher:"
    echo "$CHATGPT_LAUNCHER"
    echo
    echo "Verwijder de app via Chromium:"
    echo
    echo "  Methode 1:"
    echo "  Open ChatGPT, klik op de drie puntjes en kies"
    echo "  'ChatGPT verwijderen' of 'App verwijderen'."
    echo
    echo "  Methode 2:"
    echo "  Open in Chromium: chrome://apps"
    echo "  Klik met rechts op ChatGPT en kies Verwijderen."
    echo

    nohup flatpak run "$CHROMIUM_ID" "chrome://apps/" \
        >/tmp/forge-chatgpt-uninstall.log 2>&1 &

    read -r -p "Druk op Enter nadat ChatGPT via Chromium is verwijderd..." _

    for _ in 1 2 3 4 5; do
        CHATGPT_LAUNCHER="$(find_chatgpt_launcher || true)"

        if [[ -z "$CHATGPT_LAUNCHER" ]]; then
            break
        fi

        sleep 1
    done

    if [[ -n "$CHATGPT_LAUNCHER" ]]; then
        echo
        echo "ChatGPT is nog steeds geregistreerd."
        echo "Er worden geen Chromium-bestanden geforceerd verwijderd."
        exit 1
    fi
fi

echo
echo "Oude handgemaakte bestanden opruimen..."

rm -f "$LEGACY_LAUNCHER"
rm -rf "$LEGACY_ICON_DIR"

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$APPLICATION_DIR"
fi

echo
echo "======================================"
echo " Verwijderen voltooid"
echo "======================================"
echo
echo "Chromium zelf blijft geïnstalleerd."
