#!/usr/bin/env bash

set -Eeuo pipefail

CHROMIUM_ID="org.chromium.Chromium"
APPLICATION_DIR="$HOME/.local/share/applications"
REQUIRED_CONFIRMATION="VERWIJDER PWA"
CHROMIUM_LOG="/tmp/forge-chatgpt-uninstall.log"

find_chatgpt_launcher() {
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
echo " Forge ChatGPT - Chromium-PWA verwijderen"
echo "========================================"
echo

CHATGPT_LAUNCHER="$(find_chatgpt_launcher || true)"

if [[ -z "$CHATGPT_LAUNCHER" ]]; then
    echo "Er is geen Chromium ChatGPT-PWA gevonden."
    echo "Er hoeft niets verwijderd te worden."
    exit 0
fi

echo "Gevonden Chromium-launcher:"
echo "$CHATGPT_LAUNCHER"
echo
echo "De PWA wordt uitsluitend handmatig via Chromium verwijderd."
echo "Chromium, de officiële ChatGPT-app en persoonlijke data worden niet verwijderd."
echo "Er worden geen Chromium-profielbestanden rechtstreeks aangepast of verwijderd."
echo
echo "Typ exact: $REQUIRED_CONFIRMATION"

if ! read -r -p "> " confirmation; then
    echo
    echo "Geen bevestiging ontvangen. Er is niets gewijzigd."
    exit 0
fi

if [[ "$confirmation" != "$REQUIRED_CONFIRMATION" ]]; then
    echo "Bevestiging komt niet exact overeen. Er is niets gewijzigd."
    exit 0
fi

if ! command -v flatpak >/dev/null 2>&1; then
    echo "Fout: Flatpak is niet beschikbaar; Chromium-appbeheer wordt niet geopend." >&2
    exit 1
fi

if ! flatpak info "$CHROMIUM_ID" >/dev/null 2>&1; then
    echo "Fout: Flatpak-Chromium is niet geïnstalleerd; appbeheer wordt niet geopend." >&2
    exit 1
fi

echo
echo "Chromium-appbeheer wordt geopend."
echo "Klik met rechts op ChatGPT en kies de optie om de app te verwijderen."
echo "Selecteer geen optie die browsergegevens of persoonlijke data wist."

nohup flatpak run "$CHROMIUM_ID" "chrome://apps/" \
    >"$CHROMIUM_LOG" 2>&1 &

if ! read -r -p "Druk op Enter nadat ChatGPT handmatig via Chromium is verwijderd..." _; then
    echo
    echo "Geen verdere invoer ontvangen; de registratie wordt nu gecontroleerd."
fi

for _ in 1 2 3 4 5; do
    CHATGPT_LAUNCHER="$(find_chatgpt_launcher || true)"

    if [[ -z "$CHATGPT_LAUNCHER" ]]; then
        break
    fi

    sleep 1
done

if [[ -n "$CHATGPT_LAUNCHER" ]]; then
    echo
    echo "De PWA staat nog geregistreerd:"
    echo "$CHATGPT_LAUNCHER"
    echo "Er worden geen bestanden geforceerd verwijderd."
    exit 1
fi

echo
echo "De Chromium-launcher is verdwenen; de PWA is niet meer geregistreerd."
echo "Chromium, de officiële ChatGPT-app en persoonlijke data zijn niet verwijderd."
