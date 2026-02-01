#!/bin/bash

# 1. Definir variables (puedes cambiarlas aquí o usar las ENV del sistema)
# Si la variable FONT_PATH no está definida en el sistema, usa una ruta por defecto
FONTS_DIRECTORY="${FONT_PATH:-./fonts}"

# 2. Recibir argumentos
INPUT_VIDEO=$1
ASS_FILE=$2
OUTPUT_VIDEO=$3

# 3. Validación simple de parámetros
if [ -z "$INPUT_VIDEO" ] || [ -z "$ASS_FILE" ] || [ -z "$OUTPUT_VIDEO" ]; then
    echo "Uso: ./burn_captions.sh video_entrada.mp4 subtitulos.ass video_salida.mp4"
    exit 1
fi

# 4. Ejecutar FFmpeg
echo "Iniciando proceso de quemado de subtítulos..."
echo "Buscando fuentes en: $FONTS_DIRECTORY"

ffmpeg -i "$INPUT_VIDEO" \
    -vf "subtitles='$ASS_FILE':fontsdir='$FONTS_DIRECTORY'" \
    -c:a copy \
    -y \
    "$OUTPUT_VIDEO"

# 5. Verificar si tuvo éxito
if [ $? -eq 0 ]; then
    echo "¡Éxito! Video generado en: $OUTPUT_VIDEO"
else
    echo "Error al procesar el video."
    exit 1
fi