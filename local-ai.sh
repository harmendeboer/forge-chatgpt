#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
VERSION_FILE="$PROJECT_DIR/VERSION"
HARDWARE_CHECK="$PROJECT_DIR/scripts/check-local-ai-hardware.sh"

if [[ ! -r "$VERSION_FILE" ]]; then
    echo "Fout: VERSION is niet leesbaar: $VERSION_FILE" >&2
    exit 1
fi

VERSION="$(<"$VERSION_FILE")"

if [[ -z "$VERSION" ]]; then
    echo "Fout: VERSION is leeg." >&2
    exit 1
fi

show_help() {
    cat <<EOF
Forge Local AI $VERSION

Gebruik:
  ./local-ai.sh [optie]

Opties:
  --help   Toon deze helptekst en verander niets.
  --check  Voer een uitsluitend lezende hardware- en omgevingscontrole uit.

Deze ontwikkelversie installeert nog niets en wijzigt geen systeeminstellingen.
EOF
}

run_hardware_check() {
    if [[ ! -f "$HARDWARE_CHECK" ]]; then
        echo "Fout: controlescript niet gevonden: $HARDWARE_CHECK" >&2
        exit 1
    fi

    if [[ ! -x "$HARDWARE_CHECK" ]]; then
        echo "Fout: controlescript is niet uitvoerbaar: $HARDWARE_CHECK" >&2
        exit 1
    fi

    exec "$HARDWARE_CHECK"
}

if (( $# > 1 )); then
    echo "Fout: geef maximaal één optie op." >&2
    echo >&2
    show_help >&2
    exit 2
fi

case "${1:-}" in
    ""|--help)
        show_help
        ;;
    --check)
        run_hardware_check
        ;;
    *)
        echo "Fout: onbekende optie: $1" >&2
        echo >&2
        show_help >&2
        exit 2
        ;;
esac
