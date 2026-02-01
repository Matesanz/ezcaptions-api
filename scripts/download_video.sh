#!/bin/bash

# 1. Recibir argumentos
URL=$1
OUTPUT_PATH=$2

# 2. Validación
if [ -z "$URL" ] || [ -z "$OUTPUT_PATH" ]; then
    echo "Uso: ./download_video.sh 'https://url-publica.mp4' './videos/video_descargado.mp4'"
    exit 1
fi

# 3. Crear carpeta de destino si no existe
mkdir -p "$(dirname "$OUTPUT_PATH")"

echo "Descargando video desde: $URL..."

# 4. Descargar usando curl
# -L sigue redirecciones (necesario para Google Drive/S3)
# -o especifica el nombre de salida
curl -L -o "$OUTPUT_PATH" "$URL"

# 5. Verificar éxito
if [ $? -eq 0 ]; then
    echo "¡Descarga completada con éxito!"
    echo "Guardado en: $OUTPUT_PATH"
else
    echo "Error al descargar el video."
    exit 1
fi