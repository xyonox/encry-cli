#!/usr/bin/env bash

set -euo pipefail

usage() {
    echo "Usage: $0 [build-file]"
    echo "Example: $0"
}

if [[ $# -gt 1 ]]; then
    usage >&2
    exit 1
fi

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
SOURCE=${1:-$SCRIPT_DIR/encry}
if [[ ! -f "$SOURCE" ]]; then
    echo "Build file not found: $SOURCE" >&2
    exit 1
fi

if [[ ! -x "$SOURCE" ]]; then
    echo "Build file is not executable: $SOURCE" >&2
    echo "Example: chmod +x \"$SOURCE\"" >&2
    exit 1
fi

if [[ -w /usr/local/bin ]]; then
    TARGET_DIR=/usr/local/bin
    install -m 0755 "$SOURCE" "$TARGET_DIR/encry"
else
    TARGET_DIR="$HOME/.local/bin"
    mkdir -p "$TARGET_DIR"

    if command -v sudo >/dev/null 2>&1; then
        read -r -p "/usr/local/bin is not writable. Install system-wide with sudo? [y/N] " answer
        if [[ "$answer" =~ ^[Yy]$ ]]; then
            sudo install -m 0755 "$SOURCE" "/usr/local/bin/encry"
            TARGET_DIR=/usr/local/bin
        else
            install -m 0755 "$SOURCE" "$TARGET_DIR/encry"
        fi
    else
        install -m 0755 "$SOURCE" "$TARGET_DIR/encry"
    fi
fi

case ":${PATH}:" in
    *":$TARGET_DIR:"*) ;;
    *)
        echo
        echo "Note: $TARGET_DIR is not in PATH yet."
        echo "Add this line to ~/.zshrc and open a new terminal:"
        echo "export PATH=\"$TARGET_DIR:\$PATH\""
        ;;
esac

echo "encry was installed to $TARGET_DIR/encry."
echo "Test: encry -h"
