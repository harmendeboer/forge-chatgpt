#!/usr/bin/env bash

set -Eeuo pipefail

PACKAGE_NAME="chatgpt"
CHATGPT_BIN="/usr/bin/chatgpt"
DESKTOP_FILE="/usr/share/applications/chatgpt.desktop"
REQUIRED_CONFIRMATION="VERWIJDER CHATGPT"

print_item() {
    printf '  %-22s : %s\n' "$1" "$2"
}

echo "========================================"
echo " Forge ChatGPT - Officiële app verwijderen"
echo "========================================"
echo

if ! command -v dpkg-query >/dev/null 2>&1; then
    echo "Fout: dpkg-query is niet beschikbaar; het pakket kan niet veilig worden gecontroleerd." >&2
    exit 1
fi

PACKAGE_STATUS="$(
    dpkg-query -W -f='${db:Status-Abbrev}' "$PACKAGE_NAME" 2>/dev/null || true
)"

if [[ "$PACKAGE_STATUS" != ii* ]]; then
    print_item "Pakket" "$PACKAGE_NAME"
    print_item "Status" "niet geïnstalleerd"
    echo
    echo "Er hoeft niets verwijderd te worden."
    exit 0
fi

PACKAGE_VERSION="$(dpkg-query -W -f='${Version}' "$PACKAGE_NAME")"
PACKAGE_ARCH="$(dpkg-query -W -f='${Architecture}' "$PACKAGE_NAME")"

print_item "Pakket" "$PACKAGE_NAME"
print_item "Status" "geïnstalleerd"
print_item "Versie" "$PACKAGE_VERSION"
print_item "Architectuur" "$PACKAGE_ARCH"

if [[ -x "$CHATGPT_BIN" ]]; then
    print_item "Executable" "$CHATGPT_BIN"
else
    print_item "Executable" "ontbreekt of is niet uitvoerbaar"
fi

if [[ -f "$DESKTOP_FILE" ]]; then
    print_item "Desktop-launcher" "$DESKTOP_FILE"
else
    print_item "Desktop-launcher" "ontbreekt"
fi

echo
echo "Uit te voeren commando:"
echo "  sudo apt-get remove $PACKAGE_NAME"
echo
echo "Alleen het pakket $PACKAGE_NAME wordt verwijderd."
echo "Gebruikersdata en persoonlijke configuratiemappen worden niet verwijderd."
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

if ! command -v apt-get >/dev/null 2>&1; then
    echo "Fout: apt-get is niet beschikbaar; er is niets verwijderd." >&2
    exit 1
fi

if ! command -v sudo >/dev/null 2>&1; then
    echo "Fout: sudo is niet beschikbaar; er is niets verwijderd." >&2
    exit 1
fi

sudo apt-get remove "$PACKAGE_NAME"

echo
echo "Pakket $PACKAGE_NAME is verwijderd. Gebruikersdata is niet verwijderd."
