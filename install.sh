#!/usr/bin/env bash

set -Eeuo pipefail

APP_URL="https://chatgpt.com"
CHROMIUM_ID="org.chromium.Chromium"

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CHECK_SCRIPT="$PROJECT_DIR/scripts/check-system.sh"

APPLICATION_DIR="$HOME/.local/share/applications"
BACKUP_DIR="$PROJECT_DIR/backups"
LEGACY_LAUNCHER="$APPLICATION_DIR/chatgpt.desktop"

trap 'echo; echo "Fout op regel $LINENO. De installatie is gestopt."; exit 1' ERR

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

case "${1:-}" in
    --check)
        if [[ ! -x "$CHECK_SCRIPT" ]]; then
            echo "Fout: controlescript niet gevonden of niet uitvoerbaar:"
            echo "$CHECK_SCRIPT"
            exit 1
        fi

        exec "$CHECK_SCRIPT"
        ;;

    "")
        ;;

    *)
        echo "Gebruik:"
        echo "  ./install.sh"
        echo "  ./install.sh --check"
        exit 2
        ;;
esac

echo "======================================"
echo " Forge ChatGPT Installer 0.2.0"
echo "======================================"
echo

echo "Projectmap:"
echo "$PROJECT_DIR"
echo

echo "[1/5] Flatpak controleren..."

if ! command -v flatpak >/dev/null 2>&1; then
    if command -v apt-get >/dev/null 2>&1; then
        echo "Flatpak wordt geïnstalleerd."

        sudo apt-get update
        sudo apt-get install -y flatpak
    else
        echo "Fout: Flatpak ontbreekt en apt-get is niet beschikbaar."
        exit 1
    fi
else
    echo "Flatpak is aanwezig."
fi

echo
echo "[2/5] Flathub controleren..."

if ! flatpak remotes --columns=name 2>/dev/null | grep -Fxq 'flathub'; then
    echo "Flathub wordt toegevoegd."

    flatpak remote-add --if-not-exists \
        flathub \
        https://flathub.org/repo/flathub.flatpakrepo
else
    echo "Flathub is aanwezig."
fi

echo
echo "[3/5] Chromium controleren..."

if ! flatpak info "$CHROMIUM_ID" >/dev/null 2>&1; then
    echo "Chromium wordt via Flatpak geïnstalleerd."

    flatpak install -y flathub "$CHROMIUM_ID"
else
    echo "Chromium is aanwezig."
fi

mkdir -p "$APPLICATION_DIR"
mkdir -p "$BACKUP_DIR"

echo
echo "[4/5] Oude handgemaakte launcher controleren..."

if [[ -f "$LEGACY_LAUNCHER" ]]; then
    LEGACY_BACKUP="$BACKUP_DIR/chatgpt.desktop.manual-$(date +%Y%m%d-%H%M%S)"

    mv "$LEGACY_LAUNCHER" "$LEGACY_BACKUP"

    echo "De oude launcher is uitgeschakeld en verplaatst naar:"
    echo "$LEGACY_BACKUP"
else
    echo "Geen actieve handgemaakte launcher gevonden."
fi

echo
echo "[5/5] Echte Chromium-webapp controleren..."

CHATGPT_LAUNCHER="$(find_chatgpt_launcher || true)"

if [[ -z "$CHATGPT_LAUNCHER" ]]; then
    echo
    echo "ChatGPT is nog niet als Chromium-webapp geregistreerd."
    echo
    echo "Chromium wordt nu geopend."
    echo
    echo "Voer in Chromium deze stappen uit:"
    echo
    echo "  1. Open https://chatgpt.com"
    echo "  2. Log eventueel in"
    echo "  3. Klik rechtsboven op de drie puntjes"
    echo "  4. Kies 'Casten, opslaan en delen'"
    echo "  5. Kies 'Pagina installeren als app'"
    echo "  6. Gebruik als naam: ChatGPT"
    echo "  7. Klik op Installeren"
    echo

    nohup flatpak run "$CHROMIUM_ID" "$APP_URL" \
        >/tmp/forge-chatgpt-chromium.log 2>&1 &

    read -r -p "Druk op Enter nadat ChatGPT als app is geïnstalleerd..." _

    for _ in 1 2 3 4 5; do
        CHATGPT_LAUNCHER="$(find_chatgpt_launcher || true)"

        if [[ -n "$CHATGPT_LAUNCHER" ]]; then
            break
        fi

        sleep 1
    done
fi

if [[ -z "$CHATGPT_LAUNCHER" ]]; then
    echo
    echo "Fout: de ChatGPT-webapp is niet gevonden."
    echo "Registreer ChatGPT eerst via Chromium en start dit script opnieuw."
    exit 1
fi

PWA_BACKUP="$BACKUP_DIR/$(basename "$CHATGPT_LAUNCHER")"
cp -a "$CHATGPT_LAUNCHER" "$PWA_BACKUP"

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$APPLICATION_DIR"
fi

echo
echo "======================================"
echo " Installatie voltooid"
echo "======================================"
echo
echo "Actieve ChatGPT-launcher:"
echo "$CHATGPT_LAUNCHER"
echo
echo "Reservekopie:"
echo "$PWA_BACKUP"
echo
echo "Open het Linux Mint-menu en zoek naar ChatGPT."
