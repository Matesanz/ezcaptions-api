#!/bin/bash

FONTS_DIR="${FONT_PATH:-/workspaces/ffmpeg/fonts}"

if [ ! -d "$FONTS_DIR" ]; then
    echo "Error: La carpeta $FONTS_DIR no existe."
    exit 1
fi

echo "-------------------------------------------------------------------------------------------------------"
echo " ANALIZADOR DE FUENTES PARA AIRTABLE & FFmpeg"
echo "-------------------------------------------------------------------------------------------------------"
printf "%-25s | %-25s | %-10s | %-10s\n" "ARCHIVO" "FONTNAME (Airtable)" "BOLD?" "ITALIC?"
echo "-------------------------------------------------------------------------------------------------------"

find "$FONTS_DIR" -type f \( -iname "*.otf" -o -iname "*.ttf" \) | while read -r font_file; do
    
    filename=$(basename "$font_file")
    
    # Extraemos la Familia, el Peso (weight) y el Slant (inclinación)
    family=$(fc-scan --format "%{family}\n" "$font_file" | head -n 1 | cut -d',' -f1)
    weight=$(fc-scan --format "%{weight}\n" "$font_file" | head -n 1)
    slant=$(fc-scan --format "%{slant}\n" "$font_file" | head -n 1)

    # Determinamos si debe ir el Bold a 1 (Weight 200 es Bold en muchas fuentes, 80 es normal)
    # En fc-scan, Bold suele ser >= 200
    if [ "$weight" -ge 200 ]; then is_bold="1"; else is_bold="0"; fi
    
    # Determinamos si es Italic (Slant 100 es Italic, 0 es Roman)
    if [ "$slant" -ge 100 ]; then is_italic="1"; else is_italic="0"; fi

    printf "%-25s | %-25s | %-10s | %-10s\n" "$filename" "$family" "$is_bold" "$is_italic"
done

echo "-------------------------------------------------------------------------------------------------------"