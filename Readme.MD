
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
