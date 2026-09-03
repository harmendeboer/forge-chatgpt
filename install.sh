#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
VERSION_FILE="$PROJECT_DIR/VERSION"

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
Forge ChatGPT Manager $VERSION

Gebruik:
  ./install.sh [optie]

Opties:
  --help      Toon deze helptekst en verander niets.
  --check     Controleer het systeem en de beschikbare installaties.
  --official  Controleer de officiële ChatGPT Linux-app en gebundelde Codex CLI.
  --pwa       Installeer of controleer de Chromium-PWA als fallback.
EOF
}

run_script() {
    local script_path="$1"

    if [[ ! -x "$script_path" ]]; then
        echo "Fout: script niet gevonden of niet uitvoerbaar:" >&2
        echo "$script_path" >&2
        exit 1
    fi

    exec "$script_path"
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
        run_script "$PROJECT_DIR/scripts/check-system.sh"
        ;;
    --official)
        run_script "$PROJECT_DIR/scripts/install-official.sh"
        ;;
    --pwa)
        run_script "$PROJECT_DIR/scripts/install-pwa.sh"
        ;;
    *)
        echo "Fout: onbekende optie: $1" >&2
        echo >&2
        show_help >&2
        exit 2
        ;;
esac
