#!/bin/bash

LOCAL_FILE=$1
BUCKET_NAME=$2  # Solo el nombre, ej: "mi-bucket-videos"
DEST_NAME=$3    # El nombre que tendrá en la nube

if [ -f "$LOCAL_FILE" ]; then
    echo "Subiendo $LOCAL_FILE a gs://$BUCKET_NAME/$DEST_NAME..."
    
    # Usamos gcloud storage que es más rápido que gsutil
    gcloud storage cp "$LOCAL_FILE" "gs://$BUCKET_NAME/$DEST_NAME"
    
    if [ $? -eq 0 ]; then
        echo "¡Subida exitosa!"
        # IMPORTANTE: Borrar el archivo local para liberar RAM de Cloud Run
        rm "$LOCAL_FILE"
        echo "Archivo local eliminado para liberar memoria."
    else
        echo "Error al subir a Google Cloud Storage."
        exit 1
    fi
else
    echo "Error: El archivo $LOCAL_FILE no existe."
    exit 1
fi