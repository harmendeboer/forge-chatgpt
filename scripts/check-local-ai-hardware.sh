#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
VERSION_FILE="$PROJECT_DIR/VERSION"

CPU_INFO_AVAILABLE="nee"
RAM_INFO_AVAILABLE="nee"
NVIDIA_RUNTIME_AVAILABLE="nee"
VRAM_READ="nee"
STORAGE_INFO_AVAILABLE="nee"
OLLAMA_INSTALLED="nee"

print_item() {
    printf '  %-32s : %s\n' "$1" "$2"
}

trim_value() {
    local value="$1"

    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
    printf '%s\n' "$value"
}

read_os_release() {
    local key
    local value

    [[ -r /etc/os-release ]] || return 0

    while IFS='=' read -r key value; do
        case "$key" in
            NAME)
                OS_NAME="$value"
                ;;
            VERSION_ID)
                OS_VERSION="$value"
                ;;
            VERSION_CODENAME)
                OS_CODENAME="$value"
                ;;
        esac
    done < /etc/os-release

    OS_NAME="${OS_NAME#\"}"
    OS_NAME="${OS_NAME%\"}"
    OS_VERSION="${OS_VERSION#\"}"
    OS_VERSION="${OS_VERSION%\"}"
    OS_CODENAME="${OS_CODENAME#\"}"
    OS_CODENAME="${OS_CODENAME%\"}"
}

lscpu_value() {
    local label="$1"

    LC_ALL=C awk -F: -v wanted="$label" '
        {
            current = $1
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", current)
            if (current == wanted) {
                value = substr($0, index($0, ":") + 1)
                gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
                print value
                exit
            }
        }
    ' <<<"$LSCPU_OUTPUT"
}

echo "========================================"
echo " Forge Local AI - Read-only controle"
echo "========================================"
echo

OS_NAME="Onbekend"
OS_VERSION="Onbekend"
OS_CODENAME="Onbekend"
read_os_release

SESSION_TYPE="${XDG_SESSION_TYPE:-Onbekend}"
case "${SESSION_TYPE,,}" in
    x11)
        SESSION_TYPE="X11"
        ;;
    wayland)
        SESSION_TYPE="Wayland"
        ;;
esac

echo "1. Systeem"
print_item "Linux-distributie" "$OS_NAME"
print_item "Distributieversie" "$OS_VERSION"
print_item "Codenaam" "$OS_CODENAME"
print_item "Kernel" "$(uname -r 2>/dev/null || printf 'Onbekend')"
print_item "Architectuur" "$(uname -m 2>/dev/null || printf 'Onbekend')"
print_item "Desktopomgeving" "${XDG_CURRENT_DESKTOP:-${DESKTOP_SESSION:-Onbekend}}"
print_item "Sessietype" "$SESSION_TYPE"
echo

echo "2. Processor"
LSCPU_OUTPUT=""
if command -v lscpu >/dev/null 2>&1; then
    LSCPU_OUTPUT="$(LC_ALL=C lscpu 2>/dev/null || true)"
fi

if [[ -n "$LSCPU_OUTPUT" ]]; then
    CPU_INFO_AVAILABLE="ja"
    print_item "Modelnaam" "$(lscpu_value 'Model name')"
    print_item "Architectuur" "$(lscpu_value 'Architecture')"
    print_item "Logische CPU's" "$(lscpu_value 'CPU(s)')"
    print_item "Cores per socket" "$(lscpu_value 'Core(s) per socket')"
    print_item "Threads per core" "$(lscpu_value 'Thread(s) per core')"
    print_item "Sockets" "$(lscpu_value 'Socket(s)')"

    CPU_VIRTUALIZATION="$(lscpu_value 'Virtualization')"
    CPU_HYPERVISOR="$(lscpu_value 'Hypervisor vendor')"
    CPU_VIRTUALIZATION_TYPE="$(lscpu_value 'Virtualization type')"
    [[ -n "$CPU_VIRTUALIZATION" ]] && print_item "Virtualisatie" "$CPU_VIRTUALIZATION"
    [[ -n "$CPU_HYPERVISOR" ]] && print_item "Hypervisor" "$CPU_HYPERVISOR"
    [[ -n "$CPU_VIRTUALIZATION_TYPE" ]] && print_item "Virtualisatietype" "$CPU_VIRTUALIZATION_TYPE"
else
    print_item "CPU-informatie" "niet beschikbaar (lscpu ontbreekt of gaf geen uitvoer)"
fi
echo

echo "3. Geheugen"
FREE_OUTPUT=""
if command -v free >/dev/null 2>&1; then
    FREE_OUTPUT="$(LC_ALL=C free -h 2>/dev/null || true)"
fi

if [[ -n "$FREE_OUTPUT" ]]; then
    RAM_TOTAL="$(LC_ALL=C awk '$1 == "Mem:" { print $2; exit }' <<<"$FREE_OUTPUT")"
    RAM_USED="$(LC_ALL=C awk '$1 == "Mem:" { print $3; exit }' <<<"$FREE_OUTPUT")"
    RAM_AVAILABLE="$(LC_ALL=C awk '$1 == "Mem:" { print $7; exit }' <<<"$FREE_OUTPUT")"
    SWAP_TOTAL="$(LC_ALL=C awk '$1 == "Swap:" { print $2; exit }' <<<"$FREE_OUTPUT")"
    SWAP_USED="$(LC_ALL=C awk '$1 == "Swap:" { print $3; exit }' <<<"$FREE_OUTPUT")"

    if [[ -n "$RAM_TOTAL" ]]; then
        RAM_INFO_AVAILABLE="ja"
        print_item "Totaal RAM" "$RAM_TOTAL"
        print_item "Gebruikt RAM" "${RAM_USED:-Onbekend}"
        print_item "Beschikbaar RAM" "${RAM_AVAILABLE:-Onbekend}"
        print_item "Totaal swap" "${SWAP_TOTAL:-Onbekend}"
        print_item "Gebruikte swap" "${SWAP_USED:-Onbekend}"
    else
        print_item "Geheugeninformatie" "free gaf geen herkenbare RAM-informatie"
    fi
else
    print_item "Geheugeninformatie" "niet beschikbaar (free ontbreekt of gaf geen uitvoer)"
fi
echo

echo "4. NVIDIA en GPU"
if command -v nvidia-smi >/dev/null 2>&1; then
    print_item "nvidia-smi" "beschikbaar"

    NVIDIA_QUERY=""
    if NVIDIA_QUERY="$(
        LC_ALL=C nvidia-smi \
            --query-gpu=index,name,driver_version,memory.total,memory.used,memory.free,temperature.gpu \
            --format=csv,noheader,nounits 2>/dev/null
    )" && [[ -n "$NVIDIA_QUERY" ]]; then
        NVIDIA_RUNTIME_AVAILABLE="ja"
        VRAM_READ="ja"
        print_item "NVIDIA-runtime" "beschikbaar; GPU-query geslaagd"
        while IFS=',' read -r gpu_index gpu_name driver_version vram_total vram_used vram_free gpu_temperature; do
            gpu_index="$(trim_value "$gpu_index")"
            gpu_name="$(trim_value "$gpu_name")"
            driver_version="$(trim_value "$driver_version")"
            vram_total="$(trim_value "$vram_total")"
            vram_used="$(trim_value "$vram_used")"
            vram_free="$(trim_value "$vram_free")"
            gpu_temperature="$(trim_value "$gpu_temperature")"

            print_item "GPU $gpu_index" "$gpu_name"
            print_item "  Driverversie" "$driver_version"
            print_item "  Totaal VRAM" "$vram_total MiB"
            print_item "  Gebruikt VRAM" "$vram_used MiB"
            print_item "  Vrij VRAM" "$vram_free MiB"
            print_item "  GPU-temperatuur" "$gpu_temperature °C"
        done <<<"$NVIDIA_QUERY"
    else
        print_item "NVIDIA-runtime" "niet uitleesbaar; GPU-query mislukt"
    fi

    NVIDIA_LIST=""
    if NVIDIA_LIST="$(LC_ALL=C nvidia-smi -L 2>/dev/null)" && [[ -n "$NVIDIA_LIST" ]]; then
        echo "  nvidia-smi -L:"
        while IFS= read -r gpu_line; do
            printf '    %s\n' "$gpu_line"
        done <<<"$NVIDIA_LIST"
    else
        print_item "nvidia-smi -L" "GPU-lijst niet beschikbaar"
    fi
else
    print_item "NVIDIA-runtime" "niet beschikbaar via nvidia-smi"

    if command -v lspci >/dev/null 2>&1; then
        PCI_GPU_OUTPUT="$(LC_ALL=C lspci 2>/dev/null | LC_ALL=C awk '
            BEGIN { IGNORECASE = 1 }
            /VGA compatible controller|3D controller|Display controller/ { print }
        ' || true)"
        if [[ -n "$PCI_GPU_OUTPUT" ]]; then
            echo "  Grafische PCI-apparaten (lspci):"
            while IFS= read -r pci_line; do
                printf '    %s\n' "$pci_line"
            done <<<"$PCI_GPU_OUTPUT"
        else
            print_item "lspci-fallback" "geen grafisch apparaat gevonden"
        fi
    else
        print_item "lspci-fallback" "lspci is niet beschikbaar"
    fi
fi

if command -v nvcc >/dev/null 2>&1; then
    NVCC_OUTPUT="$(LC_ALL=C nvcc --version 2>/dev/null || true)"
    NVCC_VERSION="$(LC_ALL=C awk '
        /release/ {
            line = $0
            sub(/^.*release[[:space:]]+/, "", line)
            sub(/,.*/, "", line)
            print line
            exit
        }
    ' <<<"$NVCC_OUTPUT")"
    print_item "nvcc-versie" "${NVCC_VERSION:-Onbekend} (niet vereist voor deze diagnose)"
else
    print_item "nvcc" "niet aanwezig; niet vereist voor deze diagnose"
fi
echo

echo "5. Opslag"
LSBLK_OUTPUT=""
if command -v lsblk >/dev/null 2>&1; then
    LSBLK_OUTPUT="$(LC_ALL=C lsblk -e 7 -o NAME,TYPE,SIZE,ROTA,FSTYPE,MOUNTPOINTS,MODEL 2>/dev/null || true)"
fi

if [[ -n "$LSBLK_OUTPUT" ]]; then
    STORAGE_INFO_AVAILABLE="ja"
    echo "  Blokapparaten (ROTA 0 = SSD, ROTA 1 = HDD):"
    while IFS= read -r storage_line; do
        printf '    %s\n' "$storage_line"
    done <<<"$LSBLK_OUTPUT"
else
    print_item "Blokapparaten" "niet beschikbaar (lsblk ontbreekt of gaf geen uitvoer)"
fi

DF_OUTPUT=""
if command -v df >/dev/null 2>&1; then
    DF_OUTPUT="$(LC_ALL=C df -hT -x tmpfs -x devtmpfs 2>/dev/null || true)"
fi

if [[ -n "$DF_OUTPUT" ]]; then
    echo "  Bestandssystemen:"
    while IFS= read -r filesystem_line; do
        printf '    %s\n' "$filesystem_line"
    done <<<"$DF_OUTPUT"
else
    print_item "Bestandssystemen" "niet beschikbaar (df ontbreekt of gaf geen uitvoer)"
fi
echo

echo "6. Ollama"
if command -v ollama >/dev/null 2>&1; then
    OLLAMA_INSTALLED="ja"
    OLLAMA_PATH="$(command -v ollama)"
    OLLAMA_VERSION="$(LC_ALL=C ollama --version 2>/dev/null || true)"
    print_item "Executable" "$OLLAMA_PATH"
    print_item "Versie" "${OLLAMA_VERSION:-Onbekend}"
else
    print_item "Ollama" "niet geïnstalleerd; dat is in deze fase normaal"
fi

if command -v systemctl >/dev/null 2>&1; then
    OLLAMA_ACTIVE=""
    OLLAMA_ENABLED=""
    OLLAMA_ACTIVE="$(LC_ALL=C systemctl is-active ollama 2>/dev/null || true)"
    OLLAMA_ENABLED="$(LC_ALL=C systemctl is-enabled ollama 2>/dev/null || true)"
    print_item "Service actief" "${OLLAMA_ACTIVE:-status niet beschikbaar}"
    print_item "Service ingeschakeld" "${OLLAMA_ENABLED:-status niet beschikbaar}"
else
    print_item "Servicestatus" "systemctl is niet beschikbaar"
fi
echo

echo "7. Forge-project"
print_item "Projectmap" "$PROJECT_DIR"
if command -v git >/dev/null 2>&1; then
    GIT_BRANCH="$(GIT_OPTIONAL_LOCKS=0 LC_ALL=C git -C "$PROJECT_DIR" branch --show-current 2>/dev/null || true)"
    GIT_STATUS="$(GIT_OPTIONAL_LOCKS=0 LC_ALL=C git -C "$PROJECT_DIR" status --short 2>/dev/null || true)"
    GIT_ORIGIN="$(GIT_OPTIONAL_LOCKS=0 LC_ALL=C git -C "$PROJECT_DIR" config --get remote.origin.url 2>/dev/null || true)"

    print_item "Huidige branch" "${GIT_BRANCH:-Onbekend}"
    if [[ -n "$GIT_STATUS" ]]; then
        print_item "Werkmap" "wijzigingen aanwezig"
    else
        print_item "Werkmap" "clean"
    fi
    print_item "Origin-URL" "${GIT_ORIGIN:-niet ingesteld}"
else
    print_item "Git" "niet beschikbaar"
fi

if [[ -r "$VERSION_FILE" ]]; then
    PROJECT_VERSION="$(<"$VERSION_FILE")"
    print_item "Huidige versie" "${PROJECT_VERSION:-Onbekend}"
else
    print_item "Huidige versie" "VERSION is niet leesbaar"
fi
echo

echo "8. Voorlopige gereedheid"
print_item "CPU-informatie beschikbaar" "$CPU_INFO_AVAILABLE"
print_item "RAM-informatie beschikbaar" "$RAM_INFO_AVAILABLE"
print_item "NVIDIA-runtime beschikbaar" "$NVIDIA_RUNTIME_AVAILABLE"
print_item "VRAM uitgelezen" "$VRAM_READ"
print_item "Opslaginformatie beschikbaar" "$STORAGE_INFO_AVAILABLE"
print_item "Ollama geïnstalleerd" "$OLLAMA_INSTALLED"
echo
echo "Geen wijzigingen uitgevoerd."
