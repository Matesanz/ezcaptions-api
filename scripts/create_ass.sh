#!/bin/bash
OUTPUT_FILE=$1

# No usamos $2, usamos directamente la variable de entorno
# printf "%s" es lo más seguro para evitar que transforme caracteres especiales
printf "%s" "$RAW_ASS_CONTENT" > "$OUTPUT_FILE"

echo "Custom ASS file created at $OUTPUT_FILE"
