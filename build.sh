#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Error: No language specified"
    echo "Usage: $0 LANG"
    exit 1
fi
LANG=$1

bash ./build_noimg.sh ${LANG}

python3 make_image.py --builddir "build_${LANG}"
