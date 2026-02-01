FROM debian:bookworm-slim

# Instalamos webhook y make
RUN apt-get update && apt-get install -y \
    webhook \
    make \
    curl \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
RUN mkdir -p ass
COPY fonts/ fonts/
COPY scripts/ scripts/
COPY hooks.json .
COPY Makefile . 

# Set ROOT environment variable to match project root
ENV ROOT=/app

# Exponemos el puerto por defecto de webhook
EXPOSE 9000

# Lanzamos el servicio
# -verbose para ver los logs en la consola de la nube
# -hooks indica dónde está tu configuración
CMD ["webhook", "-hooks", "hooks.json", "-verbose", "-port", "9000"]