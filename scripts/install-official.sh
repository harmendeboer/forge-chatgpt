#!/usr/bin/env bash

set -Eeuo pipefail

PACKAGE_NAME="chatgpt"
CHATGPT_BIN="/usr/bin/chatgpt"
DESKTOP_FILE="/usr/share/applications/chatgpt.desktop"
BUNDLED_CODEX="/usr/lib/chatgpt/resources/codex"
DOWNLOAD_URL="https://chatgpt.com/download/"

print_item() {
    printf '  %-22s : %s\n' "$1" "$2"
}

offer_download_page() {
    local answer

    echo
    echo "De officiële ChatGPT Linux-app is niet geïnstalleerd."
    echo "Download de app uitsluitend via de officiële downloadpagina:"
    echo "$DOWNLOAD_URL"
    echo
    echo "Dit script downloadt of installeert geen pakket automatisch."

    if [[ ! -t 0 ]]; then
        echo "Geen interactieve terminal; de downloadpagina wordt niet geopend."
        return 0
    fi

    if ! read -r -p "Officiële downloadpagina openen met xdg-open? [j/N] " answer; then
        echo
        echo "Geen invoer ontvangen; de downloadpagina wordt niet geopend."
        return 0
    fi

    case "${answer,,}" in
        j|ja|y|yes)
            if ! command -v xdg-open >/dev/null 2>&1; then
                echo "Fout: xdg-open is niet beschikbaar; de pagina kan niet worden geopend." >&2
                return 1
            fi

            echo "De officiële downloadpagina wordt geopend."
            xdg-open "$DOWNLOAD_URL"
            ;;
        *)
            echo "De downloadpagina wordt niet geopend."
            ;;
    esac
}

echo "========================================"
echo " Forge ChatGPT - Officiële app"
echo "========================================"
echo

if ! command -v dpkg-query >/dev/null 2>&1; then
    echo "Fout: dpkg-query is niet beschikbaar; het pakket kan niet worden gecontroleerd." >&2
    exit 1
fi

PACKAGE_STATUS="$(
    dpkg-query -W -f='${db:Status-Abbrev}' "$PACKAGE_NAME" 2>/dev/null || true
)"

if [[ "$PACKAGE_STATUS" != ii* ]]; then
    print_item "Pakket" "$PACKAGE_NAME"
    print_item "Status" "niet geïnstalleerd"
    offer_download_page
    exit 0
fi

PACKAGE_VERSION="$(dpkg-query -W -f='${Version}' "$PACKAGE_NAME")"
PACKAGE_ARCH="$(dpkg-query -W -f='${Architecture}' "$PACKAGE_NAME")"

print_item "Pakket" "$PACKAGE_NAME"
print_item "Status" "geïnstalleerd"
print_item "Versie" "$PACKAGE_VERSION"
print_item "Architectuur" "$PACKAGE_ARCH"

CHECK_FAILED=false

if [[ -x "$CHATGPT_BIN" ]]; then
    print_item "Executable" "$CHATGPT_BIN"
else
    print_item "Executable" "ontbreekt of is niet uitvoerbaar"
    CHECK_FAILED=true
fi

if [[ -f "$DESKTOP_FILE" ]]; then
    print_item "Desktop-launcher" "$DESKTOP_FILE"
else
    print_item "Desktop-launcher" "ontbreekt"
    CHECK_FAILED=true
fi

if [[ -x "$BUNDLED_CODEX" ]]; then
    print_item "Gebundelde Codex" "$BUNDLED_CODEX"

    if CODEX_VERSION="$("$BUNDLED_CODEX" --version 2>/dev/null)"; then
        print_item "Codex-versie" "${CODEX_VERSION:-onbekend}"
    else
        print_item "Codex-versie" "controle mislukt"
        CHECK_FAILED=true
    fi
else
    print_item "Gebundelde Codex" "ontbreekt of is niet uitvoerbaar"
    CHECK_FAILED=true
fi

echo

if [[ "$CHECK_FAILED" == true ]]; then
    echo "Fout: de officiële ChatGPT-installatie is onvolledig." >&2
    echo "Download zo nodig een nieuw pakket via: $DOWNLOAD_URL" >&2
    exit 1
fi

echo "De officiële ChatGPT Linux-app en de gebundelde Codex CLI zijn aanwezig."
echo "Er is niets gewijzigd."
