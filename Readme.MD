
# 🎬 Video Caption Burner (AssemblyAI + FFmpeg)

Este proyecto permite procesar transcripciones de AssemblyAI y grabarlas ("quemarlas") directamente en un video utilizando el formato de subtítulos **ASS (Advanced Substation Alpha)**, lo que permite un control total sobre el diseño (fuentes, colores, sombras y cajas).

### Desarrollo Local
```bash
docker build . -t ezcaptions-api && docker run --rm   --name ezcaptions-api   -p 9000:9000  -v ./output:/app/output ezcaptions-api
```

### CI/CD y Docker Hub

Este proyecto incluye un workflow de GitHub Actions que automáticamente:
- Buildea la imagen Docker en cada push a `main`/`master`
- Pushea la imagen a Docker Hub con tags automáticos

#### Configuración de Secrets

Para que el CI/CD funcione, necesitas configurar estos secrets en tu repositorio de GitHub:

1. Ve a Settings → Secrets and Variables → Actions
2. Agrega estos Repository Secrets:
   - `DOCKER_USERNAME`: Tu username de Docker Hub
   - `DOCKER_PASSWORD`: Tu token de acceso de Docker Hub (recomendado) o password

#### Uso desde Docker Hub
```bash
# Usar la última versión
docker pull tuusername/ffmpeg-webhook:latest
docker run --rm -p 9000:9000 -v ./output:/app/output tuusername/ffmpeg-webhook:latest
```

## 📁 Estructura del Proyecto

* `burn_captions.sh`: Script principal que ejecuta FFmpeg.
* `list_fonts.sh`: Utilidad para obtener el nombre interno real de tus fuentes `.otf`/`.ttf`.
* `Makefile`: Automatizador de tareas.
* `/fonts`: Carpeta donde debes colocar tus archivos de fuentes.
* `/videos`: Carpeta para los videos de entrada.
* `/transcriptions`: Carpeta para los archivos `.ass` generados.

---

## 🚀 Guía de Uso Rápido

### 1. Preparar las Fuentes

FFmpeg no identifica las fuentes por el nombre del archivo, sino por su nombre interno. Para saber qué nombre poner en tu archivo `.ass`:

```bash
make list

```

*Copia el nombre que aparece en la columna **"Fullname"** y úsalo en la sección `Style` de tu archivo `.ass`.*

### 2. Quemar Subtítulos

Para procesar un video usando los archivos por defecto:

```bash
make burn

```

Si quieres especificar archivos distintos:

```bash
make burn INPUT=./videos/mi_video.mp4 ASS=./transcriptions/mi_subs.ass OUTPUT=./output/final.mp4

```

---

## 🎨 Personalización del Diseño (Archivo .ass)

Dentro de tu archivo `.ass`, la línea `Style` controla la apariencia. Aquí los parámetros clave:

| Parámetro | Valor | Efecto |
| --- | --- | --- |
| **Fontname** | Nombre Interno | Usa el nombre que te dio `make list`. |
| **PrimaryColour** | `&H00FFFFFF` | Color del texto (Blanco). |
| **BorderStyle** | `1` o `3` | `1` para Borde/Sombra, `3` para **Caja (Box)**. |
| **Outline** | Numérico | Grosor del borde o de la caja. |
| **Alignment** | `2` | Centrado abajo (estilo subtítulo estándar). |

---

## 🛠️ Variables de Entorno

El sistema utiliza la variable `FONT_PATH` para saber dónde buscar tus archivos `.otf`. Puedes cambiarla globalmente:

```bash
export FONT_PATH="/tu/ruta/personalizada"

```

---


## 🐳 Notas para Integración (n8n / Docker)

1. **Fuentes Locales**: Asegúrate de que el contenedor tenga acceso a la carpeta de fuentes definida en `FONT_PATH`.
2. **Rutas**: Siempre usa rutas absolutas en entornos de automatización para evitar errores de "archivo no encontrado".
3. **Code Node**: En n8n, utiliza un nodo de código para transformar los milisegundos de la API de AssemblyAI al formato `H:MM:SS.CC` (Centésimas de segundo) que requiere el archivo `.ass`.

---

## ☁️ Integración con Google Cloud Storage

### Configuración

El sistema ahora incluye funcionalidad para subir automáticamente el video procesado a Google Cloud Storage y generar una URL firmada (V4 Signed URL) con validez de 1 hora.

#### 1. Configurar Credenciales de GCP

En Cloud Run, las credenciales se configuran automáticamente. Para desarrollo local, configura:

```bash
# Opción 1: Usar gcloud auth
gcloud auth application-default login

# Opción 2: Usar service account
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account-key.json"
```

#### 2. Crear un Bucket en GCS

```bash
# Crear bucket (debe tener un nombre único globalmente)
gsutil mb -l us-central1 gs://tu-nombre-de-bucket

# O usando gcloud
gcloud storage buckets create gs://tu-nombre-de-bucket --location=us-central1
```

#### 3. Configurar Permisos del Service Account

Tu service account necesita el rol `Storage Object Creator`:

```bash
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:YOUR_SERVICE_ACCOUNT@YOUR_PROJECT.iam.gserviceaccount.com" \
  --role="roles/storage.objectCreator"
```

### Uso en el Webhook

Cuando hagas la petición POST al endpoint `/hooks/burn`, incluye el parámetro `bucket_name`:

```bash
curl -X POST http://localhost:9000/hooks/burn \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://example.com/video.mp4",
    "id": "my-video-123",
    "ass": "...", 
    "bucket_name": "mi-bucket-videos"
  }'
```

### Respuesta

El sistema retornará un JSON con la URL firmada:

```json
{
  "status": "success",
  "url": "https://storage.googleapis.com/mi-bucket-videos/output_20260201_191130.mp4?X-Goog-Algorithm=GOOG4-RSA-SHA256&X-Goog-Credential=..."
}
```

Esta URL:
- ✅ Es válida por **1 hora**
- ✅ Permite descargar el video **sin autenticación**
- ✅ Es única para cada video procesado
- ✅ Incluye un timestamp en el nombre del archivo

### Flujo Completo

1. **create_ass**: Genera el archivo de subtítulos `.ass`
2. **download**: Descarga el video original
3. **burn**: Quema subtítulos al video
4. **upload**: Sube a GCS y genera URL firmada ⬅️ **NUEVO**
5. **remove**: Elimina archivos temporales (libera RAM)

### Variables de Entorno

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `BUCKET_NAME` | Nombre del bucket de GCS | `mi-bucket-videos` |
| `GOOGLE_APPLICATION_CREDENTIALS` | Ruta al key JSON (solo local) | `/path/to/key.json` |

### Prueba Manual

Puedes probar la subida manualmente:

```bash
# Configurar el bucket
export BUCKET_NAME="mi-bucket-videos"

# Ejecutar solo el paso de upload (asume que ya tienes un video procesado)
make upload ID=test-video-123
```

### Notas de Seguridad

- 🔒 Las URLs firmadas son seguras y temporales (1 hora)
- 🗑️ El archivo local se **elimina automáticamente** después de subir para liberar RAM en Cloud Run
- 🌐 El bucket puede ser público o privado, las URLs firmadas funcionan en ambos casos
