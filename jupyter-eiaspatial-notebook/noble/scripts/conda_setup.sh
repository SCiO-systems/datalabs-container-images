#!/bin/bash

CONDARC_FILE=~/.condarc
if [ -f "$CONDARC_FILE" ]; then
    echo "conda configuration exists."
else 
    echo "$CONDARC_FILE does not exist. writing one..."
    cat > "$CONDARC_FILE" <<EOF
envs_dirs:
  - /home/jovyan/.conda-envs/
EOF
fi