#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Error: No language specified"
    echo "Usage: $0 LANG"
    exit 1
fi
LANG=$1
meson setup "build_${LANG}" -Dlang="${LANG}"
meson compile -C "build_${LANG}"
